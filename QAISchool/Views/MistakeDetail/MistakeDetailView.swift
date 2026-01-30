//
//  MistakeDetailView.swift
//  QAI 学习助手
//
//  错题详情视图
//

import SwiftUI
import SwiftData

struct MistakeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let mistake: MistakeRecord

    @State private var showEditNotes = false
    @State private var showDeleteAlert = false
    @State private var showImage = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 原图
                originalImageSection

                // 题目文本
                questionTextSection

                // AI 分析结果
                analysisSection

                // 渐进式提示
                hintsSection

                // 个人笔记
                personalNotesSection
            }
            .padding()
        }
        .navigationTitle("错题详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        mistake.isMastered.toggle()
                        mistake.updatedAt = Date()
                        try? modelContext.save()
                    } label: {
                        Label(
                            mistake.isMastered ? "标记为未掌握" : "标记为已掌握",
                            systemImage: mistake.isMastered ? "xmark.circle" : "checkmark.circle"
                        )
                    }

                    Button {
                        showEditNotes = true
                    } label: {
                        Label("编辑笔记", systemImage: "pencil")
                    }

                    Divider()

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditNotes) {
            EditNotesSheet(mistake: mistake)
        }
        .alert("删除错题", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                deleteMistake()
            }
        } message: {
            Text("确定要删除这道错题吗？删除后无法恢复。")
        }
        .fullScreenCover(isPresented: $showImage) {
            ImageViewer(imageFileName: mistake.imageFileName)
        }
    }

    // MARK: - 原图区域
    private var originalImageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("原图")
                .font(.headline)

            Button {
                showImage = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 300)

                    ImageLoader(fileName: mistake.imageFileName)
                        .aspectRatio(contentMode: .fit)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 题目文本区域
    private var questionTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("题目")
                .font(.headline)

            Text(mistake.questionText)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - AI 分析区域
    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI 分析")
                .font(.headline)

            VStack(alignment: .leading, spacing: 16) {
                // 科目和来源
                HStack {
                    Label(mistake.subject.rawValue, systemImage: mistake.subject.iconName)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(subjectColor.opacity(0.2))
                        .foregroundStyle(subjectColor)
                        .clipShape(Capsule())

                    Spacer()

                    Label(mistake.source.rawValue, systemImage: mistake.source.iconName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // 知识点
                VStack(alignment: .leading, spacing: 6) {
                    Text("知识点")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 8) {
                        ForEach(mistake.knowledgePoints, id: \.self) { point in
                            Text(point)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }

                // 错误类型和原因
                VStack(alignment: .leading, spacing: 6) {
                    Text("错误分析")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack {
                        Label(mistake.errorType.rawValue, systemImage: mistake.errorType.iconName)
                            .font(.caption)
                            .foregroundStyle(.orange)

                        Spacer()
                    }

                    Text(mistake.errorReason)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // 难度
                HStack {
                    Text("难度")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    ForEach(1...5, id: \.self) { level in
                        Image(systemName: level <= mistake.difficultyLevel ? "star.fill" : "star")
                            .foregroundStyle(level <= mistake.difficultyLevel ? .yellow : .gray)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 提示区域
    private var hintsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("渐进式提示")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(mistake.hints.enumerated()), id: \.offset) { index, hint in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 24, height: 24)
                            .background(index == 0 ? Color.green : index == 1 ? Color.orange : Color.red)
                            .foregroundStyle(.white)
                            .clipShape(Circle())

                        Text(hint)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 个人笔记区域
    private var personalNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("个人笔记")
                    .font(.headline)

                Spacer()

                Button("编辑") {
                    showEditNotes = true
                }
                .font(.caption)
            }

            if let notes = mistake.personalNotes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.yellow.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Text("点击"编辑"添加笔记")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        showEditNotes = true
                    }
            }
        }
    }

    // MARK: - 辅助方法

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

    private func deleteMistake() {
        // 删除图片
        try? ImageStorageService.shared.delete(fileName: mistake.imageFileName)
        // 删除记录
        modelContext.delete(mistake)
        try? modelContext.save()
        // 返回
        dismiss()
    }
}

// MARK: - 图片加载器
struct ImageLoader: View {
    let fileName: String
    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.gray)
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        Task {
            do {
                let loadedImage = try ImageStorageService.shared.load(fileName: fileName)
                await MainActor.run {
                    self.image = loadedImage
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - 全屏图片查看器
struct ImageViewer: View {
    let imageFileName: String
    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?
    @State private var scale: CGFloat = 1.0

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding()
                }
            }

            Spacer()

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                    )
            } else {
                ProgressView()
                    .foregroundStyle(.white)
            }

            Spacer()
        }
        .background(.black)
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        Task {
            do {
                let loadedImage = try ImageStorageService.shared.load(fileName: imageFileName)
                await MainActor.run {
                    self.image = loadedImage
                }
            } catch {
                print("加载图片失败: \(error)")
            }
        }
    }
}

// MARK: - 编辑笔记 Sheet
struct EditNotesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let mistake: MistakeRecord

    @State private var notes: String

    init(mistake: MistakeRecord) {
        self.mistake = mistake
        self._notes = State(initialValue: mistake.personalNotes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("个人笔记") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 150)
                } footer: {
                    Text("记录你的思考、补充说明或需要注意的地方")
                }
            }
            .navigationTitle("编辑笔记")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveNotes()
                    }
                    .disabled(notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveNotes() {
        mistake.personalNotes = notes.isEmpty ? nil : notes
        mistake.updatedAt = Date()
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - FlowLayout（用于知识点标签）
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))

                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - 预览
#Preview {
    NavigationStack {
        MistakeDetailView(mistake: MistakeRecord(
            imageFileName: "test.jpg",
            questionText: "计算 1 + 1 = ?",
            subject: .math,
            knowledgePoints: ["加法运算", "基础数学"],
            errorType: .calculation,
            errorReason: "粗心大意，计算错误",
            difficultyLevel: 1,
            hints: ["再算一次", "检查计算过程", "1 加 1 等于 2"],
            source: .homework
        ))
    }
    .modelContainer(for: MistakeRecord.self, inMemory: true)
}
