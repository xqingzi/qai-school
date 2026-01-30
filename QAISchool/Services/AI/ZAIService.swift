//
//  ZAIService.swift
//  QAI 学习助手
//
//  ZAI (GLM-4.6V) API 实现
//

import Foundation
import UIKit

// MARK: - ZAI Service
final class ZAIService: AIService {
    private let configuration: AIProviderConfiguration
    private let session: URLSession

    var providerName: String { "ZAI (GLM-4.6V)" }

    init(configuration: AIProviderConfiguration) {
        self.configuration = configuration

        // 配置 URLSession
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = configuration.timeout
        config.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        self.session = URLSession(configuration: config)
    }

    // MARK: - 分析错题
    func analyzeMistake(image: UIImage, source: MistakeSource) async throws -> MistakeAnalysis {
        // 1. 验证并压缩图片
        try image.validate()
        let imageData = try image.compressedData()
        let base64Image = imageData.base64EncodedString()

        // 2. 构造请求
        let prompt = buildAnalysisPrompt(source: source)
        let request = ZAIChatRequest(
            model: configuration.model,
            messages: [
                ZAIMessage(
                    role: "user",
                    content: [
                        .text(prompt),
                        .imageURL(base64Image)
                    ]
                )
            ],
            temperature: 0.7,
            maxTokens: 2000
        )

        // 3. 调用 API
        let response: ZAIChatResponse = try await performAPICall(request)

        // 4. 解析响应
        return try parseAnalysisResponse(response, source: source)
    }

    // MARK: - 验证 API Key
    func validateAPIKey() async throws -> Bool {
        // 发送一个简单的测试请求
        let testRequest = ZAIChatRequest(
            model: configuration.model,
            messages: [
                ZAIMessage(
                    role: "user",
                    content: [
                        .text("测试")
                    ]
                )
            ],
            maxTokens: 10
        )

        do {
            let _: ZAIChatResponse = try await performAPICall(testRequest)
            return true
        } catch {
            if case AIServiceError.unauthorized = error {
                return false
            }
            throw error
        }
    }

    // MARK: - 私有方法

    /// 构造分析 Prompt
    private func buildAnalysisPrompt(source: MistakeSource) -> String {
        return """
        你是一个专业的小学教育助手。请分析这张图片中的错题。

        **任务**：
        1. 识别图片中的题目文本（包括题号）
        2. 判断科目（数学/语文/英语）
        3. 提取 1-3 个知识点
        4. 分析错误类型
        5. 分析错误原因（50字以内，中文）
        6. 评估难度（1-5，1最简单）
        7. 提供 3 个渐进式提示（从方向到具体步骤）

        **重要原则**：
        - 提示应该是启发式的，不是直接给出答案
        - 例如："再读一下题目，看看哪里可能理解错了"
        - 而不是："这道题选A"

        **输出格式**（纯 JSON）：
        ```json
        {
          "questionText": "题目文本",
          "subject": "数学/语文/英语",
          "knowledgePoints": ["知识点1", "知识点2"],
          "errorType": "计算错误/概念不清/粗心大意/审题错误/其他",
          "errorReason": "错误原因分析（50字以内）",
          "difficultyLevel": 3,
          "hints": [
            "提示1：指出方向",
            "提示2：具体步骤",
            "提示3：关键点提醒"
          ]
        }
        ```

        **题目来源**：\(source.rawValue)

        只输出 JSON，不要其他内容，不要包含 markdown 代码块标记。
        """
    }

    /// 执行 API 调用
    private func performAPICall<T: Decodable>(_ request: ZAIChatRequest) async throws -> T {
        var urlRequest = URLRequest(url: URL(string: configuration.baseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 编码请求
        urlRequest.httpBody = try JSONEncoder().encode(request)

        // 执行请求
        let (data, response) = try await session.data(for: urlRequest)

        // 检查 HTTP 响应
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        // 处理状态码
        switch httpResponse.statusCode {
        case 200...299:
            break // 成功
        case 401:
            throw AIServiceError.unauthorized
        case 429:
            throw AIServiceError.rateLimitExceeded
        case 500...599:
            throw AIServiceError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw AIServiceError.serverError(statusCode: httpResponse.statusCode)
        }

        // 解码响应
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("解码失败: \(error)")
            print("响应数据: \(String(data: data, encoding: .utf8) ?? "无")")
            throw AIServiceError.parseFailed
        }
    }

    /// 解析分析响应
    private func parseAnalysisResponse(_ response: ZAIChatResponse, source: MistakeSource) throws -> MistakeAnalysis {
        guard let content = response.choices.first?.message.content else {
            throw AIServiceError.emptyResponse
        }

        // 解析 JSON
        let analysis = try MistakeAnalysis.from(json: content)

        // 更新来源
        return MistakeAnalysis(
            id: analysis.id,
            questionText: analysis.questionText,
            subject: analysis.subject,
            knowledgePoints: analysis.knowledgePoints,
            errorType: analysis.errorType,
            errorReason: analysis.errorReason,
            difficultyLevel: analysis.difficultyLevel,
            hints: analysis.hints,
            suggestedAnswer: analysis.suggestedAnswer,
            source: source,
            analyzedAt: Date()
        )
    }
}

// MARK: - ZAI API 模型

/// ZAI 聊天请求
private struct ZAIChatRequest: Codable {
    let model: String
    let messages: [ZAIMessage]
    let temperature: Double?
    let maxTokens: Int?

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }

    init(
        model: String,
        messages: [ZAIMessage],
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.maxTokens = maxTokens
    }
}

/// ZAI 消息
private struct ZAIMessage: Codable {
    let role: String
    let content: [ZAIContent]

    init(role: String, content: [ZAIContent]) {
        self.role = role
        self.content = content
    }
}

/// ZAI 内容
private enum ZAIContent: Codable {
    case text(String)
    case imageURL(String)

    enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageURL = "image_url"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "text":
            self = .text(try container.decode(String.self, forKey: .text))
        case "image_url":
            let urlContainer = try container.nestedContainer(keyedBy: ImageURLKeys.self, forKey: .imageURL)
            self = .imageURL(try urlContainer.decode(String.self, forKey: .url))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Invalid content type"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .imageURL(let url):
            try container.encode("image_url", forKey: .type)
            var urlContainer = container.nestedContainer(keyedBy: ImageURLKeys.self, forKey: .imageURL)
            try urlContainer.encode(url, forKey: .url)
        }
    }

    enum ImageURLKeys: String, CodingKey {
        case url
    }
}

/// ZAI 响应
private struct ZAIChatResponse: Codable {
    let id: String
    let choices: [ZAIChoice]
    let usage: ZAIUsage?
}

/// ZAI 选择
private struct ZAIChoice: Codable {
    let index: Int
    let message: ZAIResponseMessage
    let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

/// ZAI 响应消息
private struct ZAIResponseMessage: Codable {
    let role: String
    let content: String
}

/// ZAI 使用情况
private struct ZAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - 单元测试
#if DEBUG
import testing

@Test
func testPromptGeneration() {
    let service = ZAIService(configuration: .zai.defaultConfiguration)
    let prompt = service.buildAnalysisPrompt(source: .homework)

    // 验证 prompt 包含关键信息
    #expect(prompt.contains("json"))
    #expect(prompt.contains("数学/语文/英语"))
    #expect(prompt.contains("家庭作业"))
    #expect(prompt.contains("启发式"))
}

@Test
func testContentEncoding() throws {
    let content: ZAIContent = .text("测试文本")
    let encoder = JSONEncoder()
    let data = try encoder.encode(content)
    let string = String(data: data, encoding: .utf8) ?? ""

    #expect(string.contains("text"))
}

@Test
func testImageURLEncoding() throws {
    let content: ZAIContent = .imageURL("data:image/jpeg;base64,test")
    let encoder = JSONEncoder()
    let data = try encoder.encode(content)
    let string = String(data: data, encoding: .utf8) ?? ""

    #expect(string.contains("image_url"))
    #expect(string.contains("data:image/jpeg;base64,test"))
}
#endif
