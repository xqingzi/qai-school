//
//  CameraViewModel.swift
//  QAI 学习助手
//
//  相机和图片选择视图模型
//

import Foundation
import UIKit
import PhotosUI

// MARK: - 拍照状态
enum CameraState {
    case idle              // 空闲
    case selectingImage    // 选择图片中
    case analyzing         // 分析中
    case success           // 成功
    case error(String)     // 错误
}

// MARK: - 相机视图模型
@MainActor
final class CameraViewModel: ObservableObject {
    // MARK: - Published 属性
    @Published var selectedImage: UIImage?
    @Published var state: CameraState = .idle
    @Published var analysisResult: MistakeAnalysis?
    @Published var errorMessage: String?
    @Published var source: MistakeSource = .homework
    @Published var progress: Double = 0.0

    // MARK: - 依赖
    private let aiService: AIServiceManager
    private let imageStorage: ImageStorageService

    // MARK: - 初始化
    init(
        aiService: AIServiceManager = .shared,
        imageStorage: ImageStorageService = .shared
    ) {
        self.aiService = aiService
        self.imageStorage = imageStorage
    }

    // MARK: - 图片选择

    /// 处理选中的图片
    func handleImageSelection(_ result: PHPickerResult) {
        state = .selectingImage

        Task {
            do {
                if let data = try await result.item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        self.selectedImage = image
                        self.state = .idle
                    }
                } else {
                    await MainActor.run {
                        self.state = .error("无法加载图片")
                    }
                }
            } catch {
                await MainActor.run {
                    self.state = .error("加载图片失败: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 处理拍摄的图片
    func handleCapturedImage(_ image: UIImage) {
        selectedImage = image
        state = .idle
    }

    /// 清除选中的图片
    func clearImage() {
        selectedImage = nil
        state = .idle
        analysisResult = nil
        errorMessage = nil
        progress = 0.0
    }

    // MARK: - 分析

    /// 分析选中的图片
    func analyzeSelectedImage() async {
        guard let image = selectedImage else {
            state = .error("请先选择图片")
            return
        }

        guard aiService.isConfigured else {
            state = .error("请先配置 API Key")
            return
        }

        state = .analyzing
        errorMessage = nil
        progress = 0.0

        do {
            // 模拟进度更新
            updateProgress()

            // 调用 AI 分析
            let analysis = try await aiService.analyzeMistake(image: image, source: source)

            // 保存图片
            let fileName = try imageStorage.save(image: image)

            // 转换为记录
            let record = analysis.toMistakeRecord(imageFileName: fileName)

            // 保存到数据库（需要在 View 中通过 ModelContext 保存）
            await MainActor.run {
                self.analysisResult = analysis
                self.state = .success
                self.progress = 1.0
            }

        } catch let error as AIServiceError {
            await MainActor.run {
                self.state = .error(error.errorDescription ?? "未知错误")
                self.errorMessage = error.errorDescription
            }
        } catch {
            await MainActor.run {
                self.state = .error(error.localizedDescription)
                self.errorMessage = error.localizedDescription
            }
        }
    }

    /// 更新进度（模拟）
    private func updateProgress() {
        Task {
            for i in 1...5 {
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
                await MainActor.run {
                    self.progress = Double(i) * 0.15
                }
            }
        }
    }

    // MARK: - 便捷方法

    /// 重置状态
    func reset() {
        selectedImage = nil
        state = .idle
        analysisResult = nil
        errorMessage = nil
        progress = 0.0
    }

    /// 是否可以分析
    var canAnalyze: Bool {
        selectedImage != nil && aiService.isConfigured
    }

    /// 错误描述
    var errorDescription: String? {
        if case .error(let message) = state {
            return message
        }
        return errorMessage
    }
}

// MARK: - 状态检查
extension CameraViewModel {
    var isIdle: Bool {
        if case .idle = state {
            return true
        }
        return false
    }

    var isSelectingImage: Bool {
        if case .selectingImage = state {
            return true
        }
        return false
    }

    var isAnalyzing: Bool {
        if case .analyzing = state {
            return true
        }
        return false
    }

    var isSuccess: Bool {
        if case .success = state {
            return true
        }
        return false
    }

    var hasError: Bool {
        if case .error = state {
            return true
        }
        return false
    }
}

// MARK: - 单元测试
#if DEBUG
import testing
@testable import QAISchool

@Test
func testCameraViewModelStates() {
    let viewModel = CameraViewModel()

    // 初始状态
    #expect(viewModel.isIdle)
    #expect(!viewModel.canAnalyze)

    // 设置图片
    viewModel.selectedImage = UIImage(systemName: "star")
    // 注意：isConfigured 取决于 AIServiceManager，可能需要 mock
}

@Test
func testClearImage() {
    let viewModel = CameraViewModel()

    viewModel.selectedImage = UIImage(systemName: "star")
    viewModel.state = .success

    viewModel.clearImage()

    #expect(viewModel.selectedImage == nil)
    #expect(viewModel.isIdle)
}
#endif
