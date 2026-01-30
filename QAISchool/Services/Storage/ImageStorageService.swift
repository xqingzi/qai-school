//
//  ImageStorageService.swift
//  QAI 学习助手
//
//  图片存储服务（文件系统）
//

import Foundation
import UIKit

// MARK: - 图片存储错误
enum ImageStorageError: Error {
    case directoryNotFound
    case fileNotFound
    case saveFailed
    case deleteFailed
    case invalidFileName

    var localizedDescription: String {
        switch self {
        case .directoryNotFound:
            return "存储目录不存在"
        case .fileNotFound:
            return "图片文件不存在"
        case .saveFailed:
            return "保存图片失败"
        case .deleteFailed:
            return "删除图片失败"
        case .invalidFileName:
            return "无效的文件名"
        }
    }
}

// MARK: - 图片存储服务
final class ImageStorageService {
    // MARK: - 单例
    static let shared = ImageStorageService()

    // MARK: - 常量
    private let imagesDirectory = "mistakes"
    private let fileManager = FileManager.default

    // MARK: - 计算属性
    /// 图片存储目录 URL
    private var imagesDirectoryURL: URL {
        guard let documentsURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("无法获取 Application Support 目录")
        }

        let directory = documentsURL.appendingPathComponent(imagesDirectory)

        // 确保目录存在
        createDirectoryIfNeeded(at: directory)

        return directory
    }

    // MARK: - 初始化
    private init() {
        // 确保存储目录存在
        createDirectoryIfNeeded(at: imagesDirectoryURL)
    }

    // MARK: - 私有方法

    /// 创建目录（如果不存在）
    private func createDirectoryIfNeeded(at url: URL) {
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                print("创建目录失败: \(error)")
            }
        }
    }

    /// 生成唯一文件名
    private func generateFileName() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = UUID().uuidString.prefix(8)
        return "mistake_\(timestamp)_\(random).jpg"
    }

    /// 验证文件名
    private func validateFileName(_ fileName: String) throws {
        guard !fileName.isEmpty else {
            throw ImageStorageError.invalidFileName
        }

        // 简单的文件名格式检查
        guard fileName.hasSuffix(".jpg") || fileName.hasSuffix(".jpeg") || fileName.hasSuffix(".png") else {
            throw ImageStorageError.invalidFileName
        }
    }

    // MARK: - 公开方法

    /// 保存图片
    /// - Parameter image: 要保存的图片
    /// - Returns: 文件名
    func save(image: UIImage) throws -> String {
        // 1. 压缩图片
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ImageStorageError.saveFailed
        }

        // 2. 生成文件名
        let fileName = generateFileName()
        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)

        // 3. 写入文件
        do {
            try imageData.write(to: fileURL)
            return fileName
        } catch {
            print("保存图片失败: \(error)")
            throw ImageStorageError.saveFailed
        }
    }

    /// 加载图片
    /// - Parameter fileName: 文件名
    /// - Returns: UIImage
    func load(fileName: String) throws -> UIImage {
        try validateFileName(fileName)

        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw ImageStorageError.fileNotFound
        }

        guard let image = UIImage(contentsOfFile: fileURL.path) else {
            throw ImageStorageError.fileNotFound
        }

        return image
    }

    /// 删除图片
    /// - Parameter fileName: 文件名
    func delete(fileName: String) throws {
        try validateFileName(fileName)

        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw ImageStorageError.fileNotFound
        }

        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            print("删除图片失败: \(error)")
            throw ImageStorageError.deleteFailed
        }
    }

    /// 获取图片文件大小（字节）
    func fileSize(fileName: String) throws -> Int {
        try validateFileName(fileName)

        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw ImageStorageError.fileNotFound
        }

        let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
        return attributes[.size] as? Int ?? 0
    }

    /// 获取所有存储的图片文件名
    func allFileNames() throws -> [String] {
        try fileManager.contentsOfDirectory(atPath: imagesDirectoryURL.path)
            .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") || $0.hasSuffix(".png") }
    }

    /// 清除所有图片
    func clearAll() throws {
        let fileNames = try allFileNames()

        for fileName in fileNames {
            try? delete(fileName: fileName)
        }
    }

    /// 获取总存储大小（字节）
    func totalStorageSize() throws -> Int {
        let fileNames = try allFileNames()
        var totalSize = 0

        for fileName in fileNames {
            totalSize += try fileSize(fileName: fileName)
        }

        return totalSize
    }
}

// MARK: - 便捷扩展
extension ImageStorageService {
    /// 加载图片（返回可选）
    func loadIfExists(fileName: String) -> UIImage? {
        do {
            return try load(fileName: fileName)
        } catch {
            return nil
        }
    }

    /// 删除图片（忽略错误）
    func deleteIfExist(fileName: String) {
        try? delete(fileName: fileName)
    }

    /// 格式化文件大小
    static func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - 单元测试
#if DEBUG
import testing

@Test
func testSaveAndLoadImage() throws {
    let service = ImageStorageService.shared

    // 创建测试图片
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    UIColor.blue.setFill()
    UIGraphicsGetCurrentContext()?.fill(CGRect(origin: .zero, size: size))
    let testImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    UIGraphicsEndImageContext()

    // 保存
    let fileName = try service.save(image: testImage)

    // 加载
    let loadedImage = try service.load(fileName: fileName)

    // 验证尺寸
    #expect(loadedImage.size == testImage.size)

    // 清理
    try service.delete(fileName: fileName)
}

@Test
func testGenerateFileName() {
    let service = ImageStorageService.shared

    let fileName1 = service.generateFileName()
    let fileName2 = service.generateFileName()

    // 文件名应该不同
    #expect(fileName1 != fileName2)

    // 文件名应该以 .jpg 结尾
    #expect(fileName1.hasSuffix(".jpg"))
    #expect(fileName2.hasSuffix(".jpg"))
}

@Test
func testDeleteImage() {
    let service = ImageStorageService.shared

    // 创建测试图片
    let testImage = UIImage(systemName: "star")!

    // 保存
    let fileName = try! service.save(image: testImage)

    // 验证存在
    var exists = service.loadIfExists(fileName: fileName) != nil
    #expect(exists)

    // 删除
    try! service.delete(fileName: fileName)

    // 验证不存在
    exists = service.loadIfExists(fileName: fileName) != nil
    #expect(!exists)
}

@Test
func testFileSize() {
    let service = ImageStorageService.shared

    // 创建测试图片
    let size = CGSize(width: 500, height: 500)
    UIGraphicsBeginImageContext(size)
    UIColor.red.setFill()
    UIGraphicsGetCurrentContext()?.fill(CGRect(origin: .zero, size: size))
    let testImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    UIGraphicsEndImageContext()

    // 保存
    let fileName = try! service.save(image: testImage)

    // 获取文件大小
    let size = try! service.fileSize(fileName: fileName)

    // 应该大于 0
    #expect(size > 0)

    // 格式化大小
    let formatted = ImageStorageService.formatFileSize(size)
    print("文件大小: \(formatted)")

    // 清理
    try! service.delete(fileName: fileName)
}

@Test
func testValidateFileName() {
    let service = ImageStorageService.shared

    // 有效文件名
    #expect {
        try service.validateFileName("test.jpg")
        return true
    }

    // 无效文件名
    #expect(throws: ImageStorageError.self) {
        try service.validateFileName("")
    }

    #expect(throws: ImageStorageError.self) {
        try service.validateFileName("test.txt")
    }
}
#endif
