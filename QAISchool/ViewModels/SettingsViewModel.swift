//
//  SettingsViewModel.swift
//  QAI 学习助手
//
//  设置视图模型
//

import Foundation
import SwiftData

// MARK: - 设置视图模型
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published 属性
    @Published var selectedProvider: AIProvider = .zai
    @Published var apiKey: String = ""
    @Published var apiKeyMasked: String = ""
    @Published var isValidatingKey = false
    @Published var isKeyValid: Bool?
    @Published var errorMessage: String?
    @Published var showSuccessMessage = false

    // MARK: - 依赖
    private let aiService: AIServiceManager
    private let keychain: KeychainService

    // MARK: - 计算属性

    /// 是否有 API Key
    var hasAPIKey: Bool {
        !apiKeyMasked.isEmpty || !apiKey.isEmpty
    }

    /// API Key 状态描述
    var keyStatusDescription: String {
        if let isValid = isKeyValid {
            return isValid ? "API Key 有效" : "API Key 无效"
        }
        return hasAPIKey ? "已配置" : "未配置"
    }

    // MARK: - 初始化
    init(
        aiService: AIServiceManager = .shared,
        keychain: KeychainService = .shared
    ) {
        self.aiService = aiService
        self.keychain = keychain

        // 加载当前配置
        loadCurrentConfiguration()
    }

    // MARK: - 加载配置

    /// 加载当前配置
    func loadCurrentConfiguration() {
        selectedProvider = aiService.currentProvider

        // 加载 API Key（脱敏）
        if let maskedKey = aiService.getCurrentAPIKeyMasked() {
            apiKeyMasked = maskedKey
        } else {
            apiKeyMasked = ""
        }

        apiKey = ""
    }

    /// 切换 Provider
    func switchProvider(to provider: AIProvider) {
        selectedProvider = provider

        // 尝试加载该 provider 的 API Key
        do {
            let key = try keychain.getAPIKey(for: provider)
            apiKeyMasked = maskKey(key)
        } catch {
            apiKeyMasked = ""
        }

        apiKey = ""
        isKeyValid = nil
    }

    // MARK: - API Key 管理

    /// 保存 API Key
    func saveAPIKey() async throws {
        // 验证输入
        guard !apiKey.isEmpty else {
            throw SettingsError.emptyAPIKey
        }

        // 保存到 Keychain
        try keychain.saveAPIKey(apiKey, for: selectedProvider)

        // 配置 AI Service
        aiService.configure(with: selectedProvider, apiKey: apiKey)

        // 更新脱敏显示
        apiKeyMasked = maskKey(apiKey)

        // 清空输入
        apiKey = ""

        // 显示成功消息
        showSuccessMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showSuccessMessage = false
        }
    }

    /// 验证 API Key
    func validateAPIKey() async {
        guard !apiKey.isEmpty else {
            errorMessage = "请输入 API Key"
            return
        }

        isValidatingKey = true
        errorMessage = nil

        do {
            // 临时配置以验证
            aiService.configure(with: selectedProvider, apiKey: apiKey)

            let isValid = try await aiService.validateAPIKey()

            await MainActor.run {
                self.isKeyValid = isValid
                self.isValidatingKey = false

                if isValid {
                    // 保存有效的 Key
                    Task {
                        try? await self.saveAPIKey()
                    }
                } else {
                    self.errorMessage = "API Key 无效，请检查"
                }
            }

        } catch {
            await MainActor.run {
                self.isValidatingKey = false
                self.isKeyValid = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    /// 删除 API Key
    func deleteAPIKey() throws {
        try keychain.deleteAPIKey(for: selectedProvider)
        apiKeyMasked = ""
        apiKey = ""
        isKeyValid = nil
    }

    // MARK: - 统计信息

    /// 获取存储使用情况
    func getStorageUsage() -> String {
        do {
            let storage = ImageStorageService.shared
            let totalSize = try storage.totalStorageSize()
            return ImageStorageService.formatFileSize(totalSize)
        } catch {
            return "未知"
        }
    }

    /// 获取错题总数
    func getTotalMistakesCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<MistakeRecord>()
        do {
            return try context.fetchCount(descriptor)
        } catch {
            return 0
        }
    }

    /// 获取未掌握的错题数
    func getNotMasteredCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<MistakeRecord>(
            predicate: #Predicate { $0.isMastered == false }
        )
        do {
            return try context.fetchCount(descriptor)
        } catch {
            return 0
        }
    }

    // MARK: - 私有方法

    /// 脱敏 API Key
    private func maskKey(_ key: String) -> String {
        if key.count <= 8 {
            return String(repeating: "*", count: key.count)
        }

        let prefix = String(key.prefix(4))
        let suffix = String(key.suffix(4))
        let stars = String(repeating: "*", count: key.count - 8)

        return prefix + stars + suffix
    }
}

// MARK: - 设置错误
enum SettingsError: Error, LocalizedError {
    case emptyAPIKey
    case invalidAPIKey
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .emptyAPIKey:
            return "API Key 不能为空"
        case .invalidAPIKey:
            return "API Key 无效"
        case .saveFailed:
            return "保存失败"
        }
    }
}

// MARK: - 便捷方法
extension SettingsViewModel {
    /// 清除错误消息
    func clearError() {
        errorMessage = nil
    }

    /// 重置状态
    func reset() {
        apiKey = ""
        isKeyValid = nil
        errorMessage = nil
    }
}

// MARK: - 单元测试
#if DEBUG
import testing

@Test
func testMaskKey() {
    let viewModel = SettingsViewModel()

    let key = "sk-1234567890abcdef"
    let masked = viewModel.maskKey(key)

    // 验证脱敏
    #expect(masked.contains("sk-1"))
    #expect(masked.contains("def"))
    #expect(masked.count == key.count)
    #expect(masked.filter { $0 == "*" }.count == key.count - 8)
}

@Test
func testHasAPIKey() {
    let viewModel = SettingsViewModel()

    // 初始状态
    #expect(!viewModel.hasAPIKey)

    // 设置脱敏 Key
    viewModel.apiKeyMasked = "sk-1****def"
    #expect(viewModel.hasAPIKey)

    // 设置原始 Key
    viewModel.apiKeyMasked = ""
    viewModel.apiKey = "test-key"
    #expect(viewModel.hasAPIKey)
}
#endif
