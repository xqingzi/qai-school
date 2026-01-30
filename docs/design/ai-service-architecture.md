# AI Service 架构设计

## 设计目标

1. **灵活切换**：方便在不同 LLM provider 之间切换
2. **易于扩展**：未来支持新的 API 不需要大改代码
3. **成本控制**：能够跟踪和比较不同 API 的效果和成本
4. **安全性**：API Key 安全存储

## 架构设计

### 1. 核心接口

```swift
// MARK: - AI Service Protocol
protocol AIService {
    /// 分析错题图片
    func analyzeMistake(image: UIImage, source: MistakeSource) async throws -> MistakeAnalysis

    /// 验证 API Key 是否有效
    func validateAPIKey() async throws -> Bool

    /// Provider 名称
    var providerName: String { get }
}

// MARK: - Analysis Result
struct MistakeAnalysis: Codable {
    let id: UUID
    let questionText: String          // 题目文本
    let subject: Subject               // 科目：数学/语文/英语
    let knowledgePoints: [String]      // 知识点
    let errorType: ErrorType           // 错误类型
    let errorReason: String            // 错误原因分析
    let difficultyLevel: Int           // 难度 1-5
    let hints: [String]                // 渐进式提示
    let suggestedAnswer: String?       // 参考答案（可选）
}

enum Subject: String, Codable, CaseIterable {
    case math = "数学"
    case chinese = "语文"
    case english = "英语"
}

enum ErrorType: String, Codable, CaseIterable {
    case calculation = "计算错误"
    case concept = "概念不清"
    case careless = "粗心大意"
    case misunderstanding = "审题错误"
    case other = "其他"
}

enum MistakeSource: String, Codable, CaseIterable {
    case school = "校内练习"
    case homework = "家庭作业"
    case selfStudy = "自主练习"
}
```

### 2. Provider 配置

```swift
// MARK: - AI Provider Configuration
struct AIProviderConfiguration: Codable {
    let provider: AIProvider
    let apiKey: String
    let baseURL: String
    let model: String
}

enum AIProvider: String, Codable, CaseIterable {
    case zai = "ZAI"
    case deepseek = "DeepSeek"
    case openai = "OpenAI"  // 未来扩展

    var displayName: String {
        return self.rawValue
    }
}
```

### 3. Service 实现

```swift
// MARK: - ZAI Service Implementation
final class ZAIService: AIService {
    private let configuration: AIProviderConfiguration

    init(configuration: AIProviderConfiguration) {
        self.configuration = configuration
    }

    var providerName: String { "ZAI" }

    func analyzeMistake(image: UIImage, source: MistakeSource) async throws -> MistakeAnalysis {
        // 1. 将图片转换为 base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AIServiceError.imageConversionFailed
        }

        let base64Image = imageData.base64EncodedString()

        // 2. 构造请求
        let prompt = buildAnalysisPrompt(source: source)
        let request = ZAIRequest(
            model: configuration.model,
            messages: [
                Message(role: "user", content: [
                    .text(prompt),
                    .imageURL(base64Image)
                ])
            ]
        )

        // 3. 调用 API
        let response: ZAIResponse = try await performAPICall(request)

        // 4. 解析响应
        return try parseAnalysisResponse(response)
    }

    func validateAPIKey() async throws -> Bool {
        // 简单的测试请求验证 API Key
        let testRequest = ZAIRequest(
            model: configuration.model,
            messages: [
                Message(role: "user", content: [.text("测试")])
            ]
        )

        do {
            let _: ZAIResponse = try await performAPICall(testRequest)
            return true
        } catch {
            if case AIServiceError.unauthorized = error {
                return false
            }
            throw error
        }
    }

    private func buildAnalysisPrompt(source: MistakeSource) -> String {
        return """
        请分析这张图片中的错题。

        **要求**：
        1. 识别图片中的题目文本（包括题号）
        2. 判断科目（数学/语文/英语）
        3. 提取 1-3 个知识点
        4. 分析错误类型（计算错误/概念不清/粗心大意/审题错误/其他）
        5. 分析错误原因（50字以内）
        6. 评估难度（1-5，1最简单）
        7. 提供 3 个渐进式提示（从方向提示到具体步骤）

        **输出格式**（JSON）：
        {
            "questionText": "题目文本",
            "subject": "数学/语文/英语",
            "knowledgePoints": ["知识点1", "知识点2"],
            "errorType": "计算错误/概念不清/粗心大意/审题错误/其他",
            "errorReason": "错误原因分析",
            "difficultyLevel": 3,
            "hints": ["提示1：方向", "提示2：步骤", "提示3：具体"]
        }

        **重要**：
        - 题目来源：\(source.rawValue)
        - 只输出 JSON，不要其他内容
        - 确保是有效的 JSON 格式
        """
    }

    private func performAPICall<T: Decodable>(_ request: ZAIRequest) async throws -> T {
        var urlRequest = URLRequest(url: URL(string: configuration.baseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(T.self, from: data)
        case 401:
            throw AIServiceError.unauthorized
        case 429:
            throw AIServiceError.rateLimitExceeded
        default:
            throw AIServiceError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    private func parseAnalysisResponse(_ response: ZAIResponse) throws -> MistakeAnalysis {
        // 从 LLM 响应中提取 JSON
        guard let content = response.choices.first?.message.content else {
            throw AIServiceError.emptyResponse
        }

        // 尝试解析 JSON（可能需要清理 markdown 代码块标记）
        let jsonContent = cleanMarkdownCodeBlock(content)

        guard let data = jsonContent.data(using: .utf8) else {
            throw AIServiceError.parseFailed
        }

        do {
            let rawAnalysis = try JSONDecoder().decode(RawMistakeAnalysis.self, from: data)

            return MistakeAnalysis(
                id: UUID(),
                questionText: rawAnalysis.questionText,
                subject: Subject(rawValue: rawAnalysis.subject) ?? .math,
                knowledgePoints: rawAnalysis.knowledgePoints,
                errorType: ErrorType(rawValue: rawAnalysis.errorType) ?? .other,
                errorReason: rawAnalysis.errorReason,
                difficultyLevel: rawAnalysis.difficultyLevel,
                hints: rawAnalysis.hints,
                suggestedAnswer: nil
            )
        } catch {
            throw AIServiceError.parseFailed
        }
    }

    private func cleanMarkdownCodeBlock(_ text: String) -> String {
        // 移除 ```json 和 ``` 标记
        text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - DeepSeek Service (类似实现)
final class DeepSeekService: AIService {
    // 实现类似 ZAIService，但 API 格式可能不同
    // ...
}
```

### 4. Service Manager

```swift
// MARK: - AI Service Manager
@MainActor
final class AIServiceManager: ObservableObject {
    @Published var currentProvider: AIProvider = .zai
    @Published var isValidatingKey = false

    private var service: AIService?

    func configure(with provider: AIProvider, apiKey: String) {
        let config: AIProviderConfiguration

        switch provider {
        case .zai:
            config = AIProviderConfiguration(
                provider: provider,
                apiKey: apiKey,
                baseURL: "https://api.zai.app/v1/chat/completions",
                model: "gpt-4o"  // 示例模型名
            )
        case .deepseek:
            config = AIProviderConfiguration(
                provider: provider,
                apiKey: apiKey,
                baseURL: "https://api.deepseek.com/v1/chat/completions",
                model: "deepseek-chat"
            )
        case .openai:
            config = AIProviderConfiguration(
                provider: provider,
                apiKey: apiKey,
                baseURL: "https://api.openai.com/v1/chat/completions",
                model: "gpt-4-vision-preview"
            )
        }

        switch provider {
        case .zai:
            service = ZAIService(configuration: config)
        case .deepseek:
            service = DeepSeekService(configuration: config)
        case .openai:
            service = OpenAIService(configuration: config)
        }
    }

    func analyzeMistake(image: UIImage, source: MistakeSource) async throws -> MistakeAnalysis {
        guard let service = service else {
            throw AIServiceError.notConfigured
        }

        return try await service.analyzeMistake(image: image, source: source)
    }

    func validateAPIKey() async throws -> Bool {
        guard let service = service else {
            throw AIServiceError.notConfigured
        }

        isValidatingKey = true
        defer { isValidatingKey = false }

        return try await service.validateAPIKey()
    }
}

// MARK: - Errors
enum AIServiceError: LocalizedError {
    case notConfigured
    case imageConversionFailed
    case invalidResponse
    case unauthorized
    case rateLimitExceeded
    case serverError(statusCode: Int)
    case emptyResponse
    case parseFailed
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "AI 服务未配置，请在设置中添加 API Key"
        case .imageConversionFailed:
            return "图片处理失败"
        case .invalidResponse:
            return "服务器响应无效"
        case .unauthorized:
            return "API Key 无效，请检查设置"
        case .rateLimitExceeded:
            return "API 调用次数已达上限"
        case .serverError(let code):
            return "服务器错误 (状态码: \(code))"
        case .emptyResponse:
            return "AI 返回空响应"
        case .parseFailed:
            return "解析 AI 响应失败"
        case .networkError(let error):
            return "网络错误：\(error.localizedDescription)"
        }
    }
}
```

### 5. 使用示例

```swift
// 在 ViewModel 中使用
struct CameraViewModel: View {
    @State private var aiServiceManager = AIServiceManager()
    @State private var isAnalyzing = false
    @State private var analysisError: AIServiceError?

    func analyzeImage(_ image: UIImage) async {
        isAnalyzing = true

        do {
            let result = try await aiServiceManager.analyzeMistake(
                image: image,
                source: .homework
            )

            // 保存到数据库
            modelContext.insert(result.toMistakeRecord())

            // 跳转到详情页
            selectedMistake = result
        } catch let error as AIServiceError {
            analysisError = error
        } catch {
            analysisError = .networkError(error)
        }

        isAnalyzing = false
    }
}
```

### 6. Keychain 安全存储

```swift
// MARK: - API Key Storage
final class APIKeyStorage {
    private let keychain = Keychain()

    private func key(for provider: AIProvider) -> String {
        return "ai.apikey.\(provider.rawValue)"
    }

    func saveAPIKey(_ key: String, for provider: AIProvider) throws {
        try keychain.set(key, key: key(for: provider))
    }

    func getAPIKey(for provider: AIProvider) throws -> String {
        guard let key = try keychain.get(key(for: provider)) else {
            throw KeychainError.notFound
        }
        return key
    }

    func deleteAPIKey(for provider: AIProvider) throws {
        try keychain.remove(key(for: provider))
    }
}

// 简单的 Keychain 包装器
final class Keychain {
    func set(_ value: String, key: String) throws {
        let data = value.data(using: .utf8)!
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ] as CFDictionary

        SecItemDelete(query)  // 先删除旧的
        let status = SecItemAdd(query, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func get(_ key: String) throws -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func remove(_ key: String) throws {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary

        let status = SecItemDelete(query)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}

enum KeychainError: Error {
    case notFound
    case unhandledError(status: OSStatus)
}
```

## 优势

1. **易于扩展**：添加新的 LLM provider 只需实现 `AIService` protocol
2. **灵活切换**：用户可以在设置中切换 provider
3. **安全存储**：API Key 使用 Keychain 加密存储
4. **统一接口**：业务代码不依赖具体 provider 实现
5. **错误处理**：统一的错误类型和用户友好的错误提示

## 未来扩展

- 添加请求日志（跟踪 API 调用次数和成本）
- 添加缓存机制（相同图片不重复分析）
- 添加请求重试和超时控制
- 添加流式响应支持（实时显示分析进度）
