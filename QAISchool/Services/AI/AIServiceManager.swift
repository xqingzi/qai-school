//
//  AIServiceManager.swift
//  QAI 学习助手
//
//  AI 服务管理器（单例）
//

import Foundation
import UIKit

// MARK: - AI 服务管理器
@MainActor
final class AIServiceManager: ObservableObject {
    // MARK: - Published 属性
    @Published var currentProvider: AIProvider = .zai
    @Published var isValidatingKey = false
    @Published var lastError: AIServiceError?

    // MARK: - 私有属性
    private var service: AIService?
    private let keychainService: KeychainService

    // MARK: - 单例
    static let shared = AIServiceManager()

    // MARK: - 初始化
    private init(keychainService: KeychainService = .shared) {
        self.keychainService = keychainService

        // 尝试加载保存的配置
        loadSavedConfiguration()
    }

    // MARK: - 配置服务

    /// 配置 AI 服务
    func configure(with provider: AIProvider, apiKey: String) {
        // 保存 API Key
        do {
            try keychainService.saveAPIKey(apiKey, for: provider)
        } catch {
            print("保存 API Key 失败: \(error)")
        }

        // 更新当前 provider
        currentProvider = provider

        // 创建服务实例
        createService(for: provider, apiKey: apiKey)
    }

    /// 创建服务实例
    private func createService(for provider: AIProvider, apiKey: String) {
        var config = provider.defaultConfiguration
        config = AIProviderConfiguration(
            provider: provider,
            apiKey: apiKey,
            baseURL: config.baseURL,
            model: config.model,
            timeout: config.timeout
        )

        switch provider {
        case .zai:
            service = ZAIService(configuration: config)
        case .deepseek:
            // service = DeepSeekService(configuration: config)
            fatalError("DeepSeek service not implemented yet")
        case .openai:
            // service = OpenAIService(configuration: config)
            fatalError("OpenAI service not implemented yet")
        }
    }

    /// 加载保存的配置
    private func loadSavedConfiguration() {
        // 尝试从 Keychain 加载 API Key
        for provider in AIProvider.allCases {
            do {
                let apiKey = try keychainService.getAPIKey(for: provider)
                configure(with: provider, apiKey: apiKey)
                return
            } catch {
                // 继续尝试下一个
                continue
            }
        }
    }

    // MARK: - 公开方法

    /// 分析错题
    func analyzeMistake(image: UIImage, source: MistakeSource) async throws -> MistakeAnalysis {
        guard let service = service else {
            lastError = .notConfigured
            throw AIServiceError.notConfigured
        }

        lastError = nil

        do {
            return try await service.analyzeMistake(image: image, source: source)
        } catch let error as AIServiceError {
            lastError = error
            throw error
        } catch {
            let networkError = AIServiceError.networkError(error)
            lastError = networkError
            throw networkError
        }
    }

    /// 验证 API Key
    func validateAPIKey() async throws -> Bool {
        guard let service = service else {
            lastError = .notConfigured
            throw AIServiceError.notConfigured
        }

        isValidatingKey = true
        defer { isValidatingKey = false }

        lastError = nil

        do {
            let result = try await service.validateAPIKey()
            lastError = nil
            return result
        } catch let error as AIServiceError {
            lastError = error
            throw error
        } catch {
            let networkError = AIServiceError.networkError(error)
            lastError = networkError
            throw networkError
        }
    }

    /// 获取当前 API Key（脱敏）
    func getCurrentAPIKeyMasked() -> String? {
        guard let service = service else { return nil }

        do {
            let key = try keychainService.getAPIKey(for: currentProvider)
            return maskAPIKey(key)
        } catch {
            return nil
        }
    }

    /// 检查是否已配置
    var isConfigured: Bool {
        return service != nil
    }

    // MARK: - 私有辅助方法

    /// 脱敏 API Key
    private func maskAPIKey(_ key: String) -> String {
        if key.count <= 8 {
            return String(repeating: "*", count: key.count)
        }

        let prefix = String(key.prefix(4))
        let suffix = String(key.suffix(4))
        let stars = String(repeating: "*", count: key.count - 8)

        return prefix + stars + suffix
    }
}

// MARK: - 便捷扩展
extension AIServiceManager {
    /// 清除配置
    func clearConfiguration() {
        service = nil
        lastError = nil

        // 清除 Keychain 中的所有 keys
        for provider in AIProvider.allCases {
            try? keychainService.deleteAPIKey(for: provider)
        }
    }

    /// 切换 Provider
    func switchProvider(to provider: AIProvider) async throws {
        // 尝试加载该 provider 的 API Key
        let apiKey = try keychainService.getAPIKey(for: provider)

        // 配置新 provider
        configure(with: provider, apiKey: apiKey)
        currentProvider = provider
    }
}

// MARK: - 单元测试
#if DEBUG
import testing

@Test
func testAPIKeyMasking() {
    let manager = AIServiceManager()

    // 测试正常 key
    let key1 = "sk-1234567890abcdef"
    let masked1 = manager.maskAPIKey(key1)
    #expect(masked1 == "sk-1****cdef")
    #expect(masked1.count == key1.count)

    // 测试短 key
    let key2 = "short"
    let masked2 = manager.maskAPIKey(key2)
    #expect(masked2 == "*****")
}

@Test
func testIsConfigured() {
    let manager = AIServiceManager()
    #expect(!manager.isConfigured)

    // 配置后应该返回 true
    manager.configure(with: .zai, apiKey: "test-key")
    #expect(manager.isConfigured)
}
#endif
