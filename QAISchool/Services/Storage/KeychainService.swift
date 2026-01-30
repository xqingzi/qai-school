//
//  KeychainService.swift
//  QAI 学习助手
//
//  Keychain 安全存储服务
//

import Foundation

// MARK: - Keychain 错误
enum KeychainError: Error {
    case notFound
    case duplicateEntry
    case unhandledError(status: OSStatus)
    case emptyKey
    case emptyValue

    var localizedDescription: String {
        switch self {
        case .notFound:
            return "未找到数据"
        case .duplicateEntry:
            return "数据已存在"
        case .unhandledError(let status):
            return "未知错误: \(status)"
        case .emptyKey:
            return "Key 不能为空"
        case .emptyValue:
            return "Value 不能为空"
        }
    }
}

// MARK: - Keychain 服务
final class KeychainService {
    // MARK: - 单例
    static let shared = KeychainService()

    // MARK: - 常量
    private let service = "com.qaischool.keychain"
    private let accessGroup: String? = nil // 如果需要 App Group，设置为对应的 group ID

    // MARK: - 初始化
    private init() {}

    // MARK: - 通用方法

    /// 保存数据
    func set(_ value: String, forKey key: String) throws {
        guard !key.isEmpty else { throw KeychainError.emptyKey }
        guard !value.isEmpty else { throw KeychainError.emptyValue }

        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked // 设备解锁时可访问
        ]

        // 先删除旧数据
        SecItemDelete(query as CFDictionary)

        // 添加新数据
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    /// 获取数据
    func get(_ key: String) throws -> String {
        guard !key.isEmpty else { throw KeychainError.emptyKey }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.unhandledError(status: errSecInternalError)
            }

            guard let value = String(data: data, encoding: .utf8) else {
                throw KeychainError.unhandledError(status: errSecEncodingError)
            }

            return value

        case errSecItemNotFound:
            throw KeychainError.notFound

        default:
            throw KeychainError.unhandledError(status: status)
        }
    }

    /// 删除数据
    func remove(_ key: String) throws {
        guard !key.isEmpty else { throw KeychainError.emptyKey }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    /// 检查数据是否存在
    func exists(_ key: String) -> Bool {
        do {
            _ = try get(key)
            return true
        } catch {
            return false
        }
    }

    /// 清除所有数据
    func clearAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}

// MARK: - API Key 专用方法
extension KeychainService {
    /// 生成 API Key 的存储键
    private func apiKeyKey(for provider: AIProvider) -> String {
        return "ai.apikey.\(provider.rawValue.lowercased())"
    }

    /// 保存 API Key
    func saveAPIKey(_ key: String, for provider: AIProvider) throws {
        try set(key, forKey: apiKeyKey(for: provider))
    }

    /// 获取 API Key
    func getAPIKey(for provider: AIProvider) throws -> String {
        return try get(apiKeyKey(for: provider))
    }

    /// 删除 API Key
    func deleteAPIKey(for provider: AIProvider) throws {
        try remove(apiKeyKey(for: provider))
    }

    /// 检查 API Key 是否存在
    func hasAPIKey(for provider: AIProvider) -> Bool {
        return exists(apiKeyKey(for: provider))
    }
}

// MARK: - 单元测试
#if DEBUG
import testing

@Test
func testKeychainSetAndGet() throws {
    let service = KeychainService.shared

    // 测试保存和读取
    let key = "test-key-\(UUID().uuidString)"
    let value = "test-value"

    try service.set(value, forKey: key)

    let retrieved = try service.get(key)
    #expect(retrieved == value)

    // 清理
    try service.remove(key)
}

@Test
func testKeychainNotFound() {
    let service = KeychainService.shared

    // 测试读取不存在的 key
    let key = "non-existent-key-\(UUID().uuidString)"

    #expect(throws: KeychainError.self) {
        try service.get(key)
    }
}

@Test
func testAPIKeyStorage() throws {
    let service = KeychainService.shared

    let provider = AIProvider.zai
    let apiKey = "sk-test-\(UUID().uuidString)"

    // 保存
    try service.saveAPIKey(apiKey, for: provider)

    // 读取
    let retrieved = try service.getAPIKey(for: provider)
    #expect(retrieved == apiKey)

    // 检查存在性
    #expect(service.hasAPIKey(for: provider))

    // 删除
    try service.deleteAPIKey(for: provider)

    // 验证已删除
    #expect(!service.hasAPIKey(for: provider))
}

@Test
func testKeychainUpdate() throws {
    let service = KeychainService.shared

    let key = "update-test-\(UUID().uuidString)"

    // 第一次保存
    try service.set("value1", forKey: key)
    var retrieved = try service.get(key)
    #expect(retrieved == "value1")

    // 更新
    try service.set("value2", forKey: key)
    retrieved = try service.get(key)
    #expect(retrieved == "value2")

    // 清理
    try service.remove(key)
}

@Test
func testEmptyKeyValidation() {
    let service = KeychainService.shared

    // 空 key
    #expect(throws: KeychainError.self) {
        try service.set("value", forKey: "")
    }

    // 空 value
    #expect(throws: KeychainError.self) {
        try service.set("", forKey: "test-key")
    }
}
#endif
