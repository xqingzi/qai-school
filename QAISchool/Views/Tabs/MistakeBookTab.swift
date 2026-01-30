//
//  MistakeBookTab.swift
//  QAI 学习助手
//
//  错题本主页面
//

import SwiftUI
import SwiftData

struct MistakeBookTab: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = MistakeListViewModel()
    @State private var showFilterSheet = false
    @State private var showCamera = false
    @State private var selectedMistake: MistakeRecord?

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.filteredMistakes.isEmpty {
                    // 空状态
                    emptyStateView
                } else {
                    // 错题列表
                    mistakeListView
                }
            }
            .navigationTitle("错题本")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if viewModel.isFiltering {
                        Button("清除") {
                            withAnimation {
                                viewModel.clearFilters()
                            }
                        }
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // 筛选按钮
                    Button {
                        showFilterSheet = true
                    } label: {
                        Image(systemName: viewModel.isFiltering ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }

                    // 添加按钮
                    Button {
                        showCamera = true
                    } label: {
                        Image(systemName: "camera.fill")
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showCamera) {
                CameraView()
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }

    // MARK: - 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("还没有错题")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("点击右上角的相机按钮开始录入")
                .font(.body)
                .foregroundStyle(.tertiary)

            Button {
                showCamera = true
            } label: {
                Label("开始录入", systemImage: "camera.fill")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - 错题列表
    private var mistakeListView: some View {
        List {
            ForEach(viewModel.filteredMistakes) { mistake in
                NavigationLink {
                    MistakeDetailView(mistake: mistake)
                } label: {
                    MistakeCard(mistake: mistake)
                }
            }
            .onDelete(perform: deleteMistakes)
        }
        .listStyle(.plain)
    }

    // MARK: - 删除操作
    private func deleteMistakes(at offsets: IndexSet) {
        let mistakesToDelete = offsets.map { viewModel.filteredMistakes[$0] }
        viewModel.delete(mistakesToDelete)
    }
}

// MARK: - 错题卡片组件
struct MistakeCard: View {
    let mistake: MistakeRecord

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 缩略图
            AsyncImage(url: nil) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 80)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    Image(systemName: "photo")
                        .frame(width: 80, height: 80)
                @unknown default:
                    EmptyView()
                }
            } placeholder: {
                Image(systemName: "photo")
                    .frame(width: 80, height: 80)
            }

            // 内容
            VStack(alignment: .leading, spacing: 6) {
                // 科目标签
                Text(mistake.subject.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(subjectColor.opacity(0.2))
                    .foregroundStyle(subjectColor)
                    .clipShape(Capsule())

                // 题目预览
                Text(mistake.questionPreview)
                    .font(.body)
                    .lineLimit(2)

                // 知识点
                Text(mistake.knowledgePointsLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // 时间和状态
                HStack {
                    Text(mistake.createdAtDescription)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    Spacer()

                    if mistake.isMastered {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    } else if mistake.needsFocus {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var subjectColor: Color {
        switch mistake.subject {
        case .math:
            return .blue
        case .chinese:
            return .red
        case .english:
            return .purple
        }
    }
}

// MARK: - 筛选 Sheet
struct FilterSheet: View {
    @ObservedObject var viewModel: MistakeListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // 科目筛选
                Section("科目") {
                    Picker("科目", selection: $viewModel.selectedSubject) {
                        Text("全部").tag(nil as Subject?)
                        ForEach(Subject.allCases, id: \.self) { subject in
                            Text(subject.rawValue).tag(subject as Subject?)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 时间筛选
                Section("时间") {
                    Picker("时间", selection: $viewModel.selectedTimeFilter) {
                        ForEach(TimeFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 来源筛选
                Section("来源") {
                    Picker("来源", selection: $viewModel.selectedSource) {
                        Text("全部").tag(nil as MistakeSource?)
                        ForEach(MistakeSource.allCases, id: \.self) { source in
                            Text(source.rawValue).tag(source as MistakeSource?)
                        }
                    }
                }

                // 掌握状态
                Section {
                    Toggle("只显示未掌握", isOn: $viewModel.showMasteredOnly)
                }
            }
            .navigationTitle("筛选")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.selectedSubject) { _, _ in applyFilters() }
            .onChange(of: viewModel.selectedTimeFilter) { _, _ in applyFilters() }
            .onChange(of: viewModel.selectedSource) { _, _ in applyFilters() }
            .onChange(of: viewModel.showMasteredOnly) { _, _ in applyFilters() }
        }
    }

    private func applyFilters() {
        viewModel.applyFilters()
    }
}

// MARK: - 预览
#Preview {
    MistakeBookTab()
        .modelContainer(for: MistakeRecord.self, inMemory: true)
}
