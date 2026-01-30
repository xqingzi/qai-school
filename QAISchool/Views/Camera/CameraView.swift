//
//  CameraView.swift
//  QAI 学习助手
//
//  相机和图片选择视图
//

import SwiftUI
import PhotosUI
import SwiftData

struct CameraView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CameraViewModel()
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showSuccessAlert = false
    @State private var showResult = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 图片选择区域
                    imageSelectionSection

                    // 来源选择
                    sourceSelectionSection

                    // 操作按钮
                    actionButtons

                    // 状态信息
                    if viewModel.isAnalyzing {
                        progressSection
                    } else if let error = viewModel.errorDescription {
                        errorSection(error)
                    }
                }
                .padding()
            }
            .navigationTitle("录入错题")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .photosPicker(
                isPresented: $showImagePicker,
                selection: .init(),
                matching: .images
            )
            .sheet(isPresented: $showCamera) {
                ImagePickerSheet(sourceType: .camera) { image in
                    viewModel.handleCapturedImage(image)
                }
            }
            .alert("分析完成", isPresented: $showSuccessAlert) {
                Button("查看") {
                    showResult = true
                }
                Button("继续录入") {
                    viewModel.clearImage()
                }
            } message: {
                Text("错题已成功分析并保存")
            }
            .navigationDestination(isPresented: $showResult) {
                if let analysis = viewModel.analysisResult {
                    // 这里需要显示详情页，暂时显示成功信息
                    Text("分析成功")
                        .navigationTitle("结果")
                }
            }
            .onChange(of: viewModel.state) { _, newState in
                if case .success = newState {
                    showSuccessAlert = true
                }
            }
        }
    }

    // MARK: - 图片选择区域
    private var imageSelectionSection: some View {
        VStack(spacing: 16) {
            Text("1. 选择错题图片")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 图片预览或占位符
            ZStack {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)

                    // 删除按钮
                    Button {
                        withAnimation {
                            viewModel.clearImage()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .background(Circle().fill(.black.opacity(0.5)))
                    }
                    .padding(8)
                    .offset(x: 180, y: -180)
                } else {
                    // 占位符
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 400)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.gray)

                                Text("请选择或拍摄错题照片")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        )
                }
            }

            // 选择按钮
            HStack(spacing: 16) {
                Button {
                    showCamera = true
                } label: {
                    Label("拍照", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isAnalyzing)

                Button {
                    showImagePicker = true
                } label: {
                    Label("相册", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isAnalyzing)
            }
        }
    }

    // MARK: - 来源选择
    private var sourceSelectionSection: some View {
        VStack(spacing: 16) {
            Text("2. 选择错题来源")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Picker("来源", selection: $viewModel.source) {
                ForEach(MistakeSource.allCases, id: \.self) { source in
                    Label(source.rawValue, systemImage: source.iconName)
                        .tag(source)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - 操作按钮
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Text("3. 开始分析")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                Task {
                    await viewModel.analyzeSelectedImage()
                }
            } label: {
                if viewModel.isAnalyzing {
                    HStack {
                        ProgressView()
                            .tint(.white)
                        Text("分析中...")
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    Label("AI 智能分析", systemImage: "brain.head.profile")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canAnalyze)
            .controlSize(.large)

            if !viewModel.canAnalyze && viewModel.selectedImage != nil {
                Text("请先配置 API Key")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    // MARK: - 进度区域
    private var progressSection: some View {
        VStack(spacing: 16) {
            ProgressView(value: viewModel.progress)

            Text("正在分析错题，请稍候...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 错误区域
    private func errorSection(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 4) {
                Text("分析失败")
                    .font(.headline)
                    .foregroundStyle(.red)

                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("重试") {
                Task {
                    await viewModel.analyzeSelectedImage()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 图片选择器 Sheet
struct ImagePickerSheet: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerSheet

        init(_ parent: ImagePickerSheet) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - 预览
#Preview {
    CameraView()
        .modelContainer(for: MistakeRecord.self, inMemory: true)
}
