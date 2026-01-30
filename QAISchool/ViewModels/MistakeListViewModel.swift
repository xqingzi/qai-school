//
//  MistakeListViewModel.swift
//  QAI 学习助手
//
//  错题列表视图模型
//

import Foundation
import SwiftData

// MARK: - 错题列表视图模型
@MainActor
final class MistakeListViewModel: ObservableObject {
    // MARK: - Published 属性
    @Published var mistakes: [MistakeRecord] = []
    @Published var filteredMistakes: [MistakeRecord] = []
    @Published var selectedSubject: Subject?
    @Published var selectedTimeFilter: TimeFilter = .all
    @Published var selectedSource: MistakeSource?
    @Published var searchText: String = ""
    @Published var isFiltering: Bool = false
    @Published var showMasteredOnly: Bool = false

    // MARK: - 依赖
    private var modelContext: ModelContext?

    // MARK: - 计算属性

    /// 是否有筛选条件
    var hasActiveFilters: Bool {
        selectedSubject != nil ||
        selectedTimeFilter != .all ||
        selectedSource != nil ||
        !searchText.isEmpty ||
        showMasteredOnly
    }

    /// 错题总数
    var totalCount: Int {
        mistakes.count
    }

    /// 筛选后的数量
    var filteredCount: Int {
        filteredMistakes.count
    }

    /// 未掌握的数量
    var notMasteredCount: Int {
        mistakes.filter { !$0.isMastered }.count
    }

    // MARK: - 初始化
    init() {}

    // MARK: - 配置

    /// 设置 ModelContext
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadMistakes()
    }

    // MARK: - 数据加载

    /// 加载所有错题
    func loadMistakes() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<MistakeRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            mistakes = try context.fetch(descriptor)
            applyFilters()
        } catch {
            print("加载错题失败: \(error)")
        }
    }

    /// 刷新数据
    func refresh() {
        loadMistakes()
    }

    // MARK: - 筛选

    /// 应用筛选
    func applyFilters() {
        var result = mistakes

        // 科目筛选
        if let subject = selectedSubject {
            result = result.filter { $0.subject == subject }
        }

        // 时间筛选
        if let startDate = selectedTimeFilter.startDate {
            result = result.filter { $0.createdAt >= startDate }
        }

        // 来源筛选
        if let source = selectedSource {
            result = result.filter { $0.source == source }
        }

        // 搜索筛选
        if !searchText.isEmpty {
            result = result.filter { mistake in
                mistake.questionText.contains(searchText) ||
                mistake.knowledgePoints.contains { $0.contains(searchText) }
            }
        }

        // 掌握状态筛选
        if showMasteredOnly {
            result = result.filter { !$0.isMastered }
        }

        filteredMistakes = result
        isFiltering = hasActiveFilters
    }

    /// 清除所有筛选
    func clearFilters() {
        selectedSubject = nil
        selectedTimeFilter = .all
        selectedSource = nil
        searchText = ""
        showMasteredOnly = false
        applyFilters()
    }

    // MARK: - CRUD 操作

    /// 删除错题
    func delete(_ mistake: MistakeRecord) {
        guard let context = modelContext else { return }

        // 删除图片文件
        if let imageStorage = try? ImageStorageService() {
            try? imageStorage.delete(fileName: mistake.imageFileName)
        }

        // 删除数据库记录
        context.delete(mistake)

        // 保存并刷新
        do {
            try context.save()
            loadMistakes()
        } catch {
            print("删除失败: \(error)")
        }
    }

    /// 批量删除
    func delete(_ mistakes: [MistakeRecord]) {
        guard let context = modelContext else { return }

        let imageStorage = ImageStorageService.shared

        for mistake in mistakes {
            // 删除图片
            try? imageStorage.delete(fileName: mistake.imageFileName)
            // 删除记录
            context.delete(mistake)
        }

        // 保存并刷新
        do {
            try context.save()
            loadMistakes()
        } catch {
            print("批量删除失败: \(error)")
        }
    }

    // MARK: - 统计

    /// 按科目统计
    func countBySubject() -> [Subject: Int] {
        var counts: [Subject: Int] = [:]

        for mistake in mistakes {
            counts[mistake.subject, default: 0] += 1
        }

        return counts
    }

    /// 按知识点统计
    func countByKnowledgePoint() -> [String: Int] {
        var counts: [String: Int] = [:]

        for mistake in mistakes {
            for point in mistake.knowledgePoints {
                counts[point, default: 0] += 1
            }
        }

        return counts
    }

    /// 获取最近一周的错题
    func getRecentMistakes(days: Int = 7) -> [MistakeRecord] {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        return mistakes.filter { $0.createdAt >= cutoffDate }
    }
}

// MARK: - 便捷方法
extension MistakeListViewModel {
    /// 搜索
    func search(_ text: String) {
        searchText = text
        applyFilters()
    }

    /// 按科目筛选
    func filter(by subject: Subject?) {
        selectedSubject = subject
        applyFilters()
    }

    /// 按时间筛选
    func filter(by timeFilter: TimeFilter) {
        selectedTimeFilter = timeFilter
        applyFilters()
    }

    /// 按来源筛选
    func filter(by source: MistakeSource?) {
        selectedSource = source
        applyFilters()
    }

    /// 切换掌握状态筛选
    func toggleMasteredFilter() {
        showMasteredOnly.toggle()
        applyFilters()
    }
}

// MARK: - 单元测试
#if DEBUG
import testing

@Test
func testApplyFilters() {
    let viewModel = MistakeListViewModel()

    // 创建测试数据
    // 注意：需要 ModelContext，实际测试需要更完整的设置
    viewModel.mistakes = []

    // 应用筛选
    viewModel.applyFilters()

    #expect(viewModel.filteredMistakes.isEmpty)
}

@Test
func testHasActiveFilters() {
    let viewModel = MistakeListViewModel()

    // 无筛选
    #expect(!viewModel.hasActiveFilters)

    // 添加筛选条件
    viewModel.searchText = "测试"
    viewModel.applyFilters()

    #expect(viewModel.hasActiveFilters)

    // 清除筛选
    viewModel.clearFilters()

    #expect(!viewModel.hasActiveFilters)
}
#endif
