//
//  SettingsTab.swift
//  QAI 学习助手
//
//  设置页面
//

import SwiftUI
import SwiftData

struct SettingsTab: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()
    @State private var showAbout = false

    var body: some View {
        NavigationStack {
            List {
                // AI 服务配置
                Section {
                    NavigationLink {
                        AIProviderConfigView(viewModel: viewModel)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI 服务配置")
                                    .font(.headline)

                                Text(viewModel.keyStatusDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if viewModel.hasAPIKey {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                } header: {
                    Text("AI 服务")
                } footer: {
                    Text("配置 API Key 以使用 AI 分析功能")
                }

                // 统计信息
                Section {
                    HStack {
                        Label("错题总数", systemImage: "book.fill")
                        Spacer()
                        Text("\(viewModel.getTotalMistakesCount(context: modelContext))")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("未掌握", systemImage: "exclamationmark.triangle.fill")
                        Spacer()
                        Text("\(viewModel.getNotMasteredCount(context: modelContext))")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("存储占用", systemImage: "externaldrive.fill")
                        Spacer()
                        Text(viewModel.getStorageUsage())
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("统计信息")
                }

                // 关于
                Section {
                    Button {
                        showAbout = true
                    } label: {
                        HStack {
                            Text("关于 QAI 学习助手")
                            Spacer()
                            Image(systemName: "info.circle")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://github.com/xuqingzi/qai-school")!) {
                        HStack {
                            Text("GitHub 仓库")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("关于")
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }
}

// MARK: - AI Provider 配置视图
struct AIProviderConfigView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool

    var body: some View {
        Form {
            // Provider 选择
            Section {
                Picker("AI 服务商", selection: $viewModel.selectedProvider) {
                    ForEach(AIProvider.allCases, id: \.self) { provider in
                        Text(provider.displayName).tag(provider)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.selectedProvider) { _, _ in
                    viewModel.switchProvider(to: viewModel.selectedProvider)
                }
            } header: {
                Text("选择服务商")
            } footer: {
                Text("当前推荐使用 ZAI (GLM-4.6V)")
            }

            // API Key 输入
            Section {
                if viewModel.hasAPIKey && viewModel.apiKey.isEmpty {
                    // 已配置状态
                    HStack {
                        Text("API Key")
                        Spacer()
                        Text(viewModel.apiKeyMasked)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button("删除") {
                            viewModel.showSuccessMessage = false
                            try? viewModel.deleteAPIKey()
                        }
                        .buttonStyle(.borderless)
                    }
                } else {
                    // 输入状态
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Key")
                            .font(.headline)

                        SecureField("粘贴 API Key", text: $viewModel.apiKey)
                            .focused($isInputFocused)

                        if !viewModel.apiKey.isEmpty {
                            HStack(spacing: 12) {
                                // 验证按钮
                                Button {
                                    Task {
                                        await viewModel.validateAPIKey()
                                    }
                                } label: {
                                    if viewModel.isValidatingKey {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("验证")
                                    }
                                }
                                .buttonStyle(.bordered)
                                .disabled(viewModel.apiKey.isEmpty)

                                // 保存按钮
                                Button {
                                    Task {
                                        try? await viewModel.saveAPIKey()
                                        isInputFocused = false
                                    }
                                } label: {
                                    Text("保存")
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(viewModel.apiKey.isEmpty)
                            }
                        }
                    }
                }
            } header: {
                Text("API Key")
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                    }

                    Text("API Key 将安全存储在 Keychain 中")
                        .font(.caption)
                }
            }

            // 使用说明
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Link("获取 ZAI API Key", destination: URL(string: "https://open.bigmodel.cn/")!)
                        .buttonStyle(.link)

                    Text("1. 访问 ZAI 官网注册账号")
                        .font(.caption)
                    Text("2. 在控制台创建 API Key")
                        .font(.caption)
                    Text("3. 复制 Key 并粘贴到上方")
                        .font(.caption)
                }
            } header: {
                Text("如何获取 API Key")
            }
        }
        .navigationTitle("AI 服务配置")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    dismiss()
                }
            }
        }
        .alert("保存成功", isPresented: $viewModel.showSuccessMessage) {
            Button("确定") { }
        } message: {
            Text("API Key 已安全保存")
        }
    }
}

// MARK: - 关于视图
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 图标
                Image(systemName: "book.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                // 信息
                VStack(spacing: 8) {
                    Text("QAI 学习助手")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("版本 1.0.0")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // 描述
                Text("帮助小学生整理错题和复习的 iPad 应用")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // 特性
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "camera.fill", title: "拍照录入", description: "AI 自动识别和分析")
                    FeatureRow(icon: "folder.fill", title: "智能归档", description: "按科目、知识点分类")
                    FeatureRow(icon: "lightbulb.fill", title: "辅助复习", description: "渐进式提示引导思考")
                }
                .padding()

                Spacer()

                // 版权信息
                Text("© 2026 QAI School")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 特性行
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - 预览
#Preview {
    SettingsTab()
        .modelContainer(for: MistakeRecord.self, inMemory: true)
}
