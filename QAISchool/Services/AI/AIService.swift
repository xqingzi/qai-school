//
//  AIService.swift
//  QAI 学习助手
//
//  AI 服务协议定义
//

import Foundation
import UIKit

// MARK: - AI 服务协议
protocol AIService {
    /// Provider 名称
    var providerName: String { get }

    /// 分析错题图片
    /// - Parameters:
    ///   - image: 错题图片
    ///   - source: 错题来源
    /// - Returns: 分析结果
    func analyzeMistake(image: UIImage, source: MistakeSource) async throws -> MistakeAnalysis

    /// 验证 API Key 是否有效
    /// - Returns: 是否有效
    func validateAPIKey() async throws -> Bool
}

// MARK: - AI 服务错误
enum AIServiceError: LocalizedError {
    case notConfigured                // 服务未配置
    case imageConversionFailed        // 图片转换失败
    case invalidResponse              // 响应无效
    case unauthorized                 // API Key 无效
    case rateLimitExceeded            // 超出速率限制
    case serverError(statusCode: Int) // 服务器错误
    case emptyResponse                // 空响应
    case parseFailed                  // 解析失败
    case networkError(Error)          // 网络错误
    case invalidImage                 // 无效图片
    case fileTooLarge                 // 文件过大
    case timeout                      // 超时

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "AI 服务未配置，请在设置中添加 API Key"
        case .imageConversionFailed:
            return "图片处理失败，请重试"
        case .invalidResponse:
            return "服务器响应无效，请稍后重试"
        case .unauthorized:
            return "API Key 无效，请检查设置"
        case .rateLimitExceeded:
            return "API 调用次数已达上限，请稍后重试"
        case .serverError(let code):
            return "服务器错误 (状态码: \(code))，请稍后重试"
        case .emptyResponse:
            return "AI 返回空响应，请重试"
        case .parseFailed:
            return "解析 AI 响应失败，请重试"
        case .networkError(let error):
            return "网络错误：\(error.localizedDescription)"
        case .invalidImage:
            return "无效的图片格式"
        case .fileTooLarge:
            return "图片文件过大，请选择小于 2MB 的图片"
        case .timeout:
            return "请求超时，请检查网络连接"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .notConfigured:
            return "前往设置页面配置 API Key"
        case .unauthorized:
            return "检查 API Key 是否正确"
        case .networkError, .timeout:
            return "检查网络连接后重试"
        case .rateLimitExceeded:
            return "等待几分钟后重试，或升级 API 套餐"
        default:
            return "请重试，如果问题持续存在请联系技术支持"
        }
    }
}

// MARK: - AI Provider 配置
struct AIProviderConfiguration: Codable {
    let provider: AIProvider
    let apiKey: String
    let baseURL: String
    let model: String
    let timeout: TimeInterval // 超时时间（秒）

    init(
        provider: AIProvider,
        apiKey: String,
        baseURL: String,
        model: String,
        timeout: TimeInterval = 30.0
    ) {
        self.provider = provider
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.model = model
        self.timeout = timeout
    }
}

// MARK: - AI Provider 枚举
enum AIProvider: String, Codable, CaseIterable {
    case zai = "ZAI"
    case deepseek = "DeepSeek"
    case openai = "OpenAI"

    var displayName: String {
        return self.rawValue
    }

    /// 默认配置
    var defaultConfiguration: AIProviderConfiguration {
        switch self {
        case .zai:
            return AIProviderConfiguration(
                provider: self,
                apiKey: "",
                baseURL: "https://open.bigmodel.cn/api/paas/v4/chat/completions",
                model: "glm-4v" // GLM-4.6V 视觉模型
            )
        case .deepseek:
            return AIProviderConfiguration(
                provider: self,
                apiKey: "",
                baseURL: "https://api.deepseek.com/v1/chat/completions",
                model: "deepseek-chat"
            )
        case .openai:
            return AIProviderConfiguration(
                provider: self,
                apiKey: "",
                baseURL: "https://api.openai.com/v1/chat/completions",
                model: "gpt-4-vision-preview"
            )
        }
    }
}

// MARK: - 图片工具
extension UIImage {
    /// 压缩并转换为 JPEG Data
    /// - Parameter maxSize: 最大文件大小（字节），默认 2MB
    /// - Returns: 压缩后的 Data
    func compressedData(maxSize: Int = 2 * 1024 * 1024) throws -> Data {
        // 1. 调整尺寸（最大 2048x2048）
        let maxDimension: CGFloat = 2048
        let scaledImage = self.resized(to: maxDimension)

        // 2. 压缩质量递减尝试
        var compression: CGFloat = 0.8
        var imageData = scaledImage.jpegData(compressionQuality: compression)

        while let data = imageData, data.count > maxSize && compression > 0.1 {
            compression -= 0.1
            imageData = scaledImage.jpegData(compressionQuality: compression)
        }

        guard let finalData = imageData, finalData.count <= maxSize else {
            throw AIServiceError.fileTooLarge
        }

        return finalData
    }

    /// 调整图片尺寸
    private func resized(to maxDimension: CGFloat) -> UIImage {
        let size = self.size

        // 如果图片已经足够小，直接返回
        if size.width <= maxDimension && size.height <= maxDimension {
            return self
        }

        // 计算缩放比例
        let scale = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        // 渲染新图片
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage ?? self
    }

    /// 验证图片是否有效
    func validate() throws {
        guard self.size.width > 0, self.size.height > 0 else {
            throw AIServiceError.invalidImage
        }

        // 检查是否为 CGImage
        guard self.cgImage != nil else {
            throw AIServiceError.invalidImage
        }
    }
}

// MARK: - 单元测试
#if DEBUG
import testing

@Test
func testImageCompression() throws {
    // 创建一个测试图片
    let size = CGSize(width: 3000, height: 3000)
    UIGraphicsBeginImageContext(size)
    UIColor.white.setFill()
    UIGraphicsGetCurrentContext()?.fill(CGRect(origin: .zero, size: size))
    let testImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    UIGraphicsEndImageContext()

    // 测试压缩
    let compressedData = try testImage.compressedData(maxSize: 1 * 1024 * 1024)

    // 验证压缩后的数据小于 1MB
    #expect(compressedData.count <= 1 * 1024 * 1024)
}

@Test
func testImageValidation() throws {
    let validImage = UIImage(systemName: "star")!
    try validImage.validate()

    // 注意：无法创建无效图片进行测试，因为 UIImage 初始化不会失败
    // 实际测试需要使用真实场景
}
#endif
