//
//  MistakeRecord.swift
//  QAI 学习助手
//
//  错题记录模型（SwiftData 持久化）
//

import Foundation
import SwiftData

// MARK: - 错题记录
@Model
final class MistakeRecord {
    var id: UUID
    var imageFileName: String        // 图片文件名
    var questionText: String         // 题目文本
    var subject: Subject             // 科目
    var knowledgePoints: [String]    // 知识点数组
    var errorType: ErrorType         // 错误类型
    var errorReason: String          // 错误原因
    var difficultyLevel: Int         // 难度 1-5
    var hints: [String]              // 渐进式提示
    var suggestedAnswer: String?     // 参考答案
    var source: MistakeSource        // 来源
    var isMastered: Bool             // 是否已掌握
    var personalNotes: String?       // 个人笔记
    var createdAt: Date              // 创建时间
    var updatedAt: Date              // 更新时间

    init(
        id: UUID = UUID(),
        imageFileName: String,
        questionText: String,
        subject: Subject,
        knowledgePoints: [String],
        errorType: ErrorType,
        errorReason: String,
        difficultyLevel: Int,
        hints: [String],
        suggestedAnswer: String? = nil,
        source: MistakeSource,
        isMastered: Bool = false,
        personalNotes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        // 验证难度等级
        precondition(difficultyLevel >= 1 && difficultyLevel <= 5, "难度等级必须在 1-5 之间")

        self.id = id
        self.imageFileName = imageFileName
        self.questionText = questionText
        self.subject = subject
        self.knowledgePoints = knowledgePoints
        self.errorType = errorType
        self.errorReason = errorReason
        self.difficultyLevel = difficultyLevel
        self.hints = hints
        self.suggestedAnswer = suggestedAnswer
        self.source = source
        self.isMastered = isMastered
        self.personalNotes = personalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - 便捷方法
extension MistakeRecord {
    /// 标记为已掌握
    func markAsMastered() {
        self.isMastered = true
        self.updatedAt = Date()
    }

    /// 标记为未掌握
    func markAsNeedsReview() {
        self.isMastered = false
        self.updatedAt = Date()
    }

    /// 更新个人笔记
    func updateNotes(_ notes: String?) {
        self.personalNotes = notes
        self.updatedAt = Date()
    }
}

// MARK: - 计算属性
extension MistakeRecord {
    /// 题目文本预览（最多100字符）
    var questionPreview: String {
        if questionText.count > 100 {
            return String(questionText.prefix(100)) + "..."
        }
        return questionText
    }

    /// 是否需要重点复习（难度高且未掌握）
    var needsFocus: Bool {
        !isMastered && difficultyLevel >= 4
    }

    /// 知识点标签（逗号分隔）
    var knowledgePointsLabel: String {
        knowledgePoints.joined(separator: "、")
    }

    /// 创建日期描述
    var createdAtDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - 单元测试
#if DEBUG
import SwiftData
import testing

@Test
func testMistakeRecordCreation() {
    let record = MistakeRecord(
        imageFileName: "test.jpg",
        questionText: "1 + 1 = ?",
        subject: .math,
        knowledgePoints: ["加法"],
        errorType: .calculation,
        errorReason: "粗心",
        difficultyLevel: 1,
        hints: ["再算一次"],
        source: .homework
    )

    #expect(record.questionText == "1 + 1 = ?")
    #expect(record.subject == .math)
    #expect(record.knowledgePoints == ["加法"])
    #expect(record.difficultyLevel == 1)
    #expect(!record.isMastered)
}

@Test
func testMarkAsMastered() {
    var record = MistakeRecord(
        imageFileName: "test.jpg",
        questionText: "测试",
        subject: .math,
        knowledgePoints: [],
        errorType: .other,
        errorReason: "测试",
        difficultyLevel: 1,
        hints: [],
        source: .homework
    )

    #expect(!record.isMastered)

    record.markAsMastered()

    #expect(record.isMastered)
}

@Test
func testQuestionPreview() {
    let longText = String(repeating: "这是一道很长的数学题", count: 10)
    let record = MistakeRecord(
        imageFileName: "test.jpg",
        questionText: longText,
        subject: .math,
        knowledgePoints: [],
        errorType: .other,
        errorReason: "测试",
        difficultyLevel: 1,
        hints: [],
        source: .homework
    )

    #expect(record.questionPreview.count <= 103) // 100 + "..."
    #expect(record.questionPreview.hasSuffix("..."))
}

@Test
func testNeedsFocus() {
    let highDifficulty = MistakeRecord(
        imageFileName: "test.jpg",
        questionText: "测试",
        subject: .math,
        knowledgePoints: [],
        errorType: .other,
        errorReason: "测试",
        difficultyLevel: 4,
        hints: [],
        source: .homework
    )

    #expect(highDifficulty.needsFocus)

    highDifficulty.markAsMastered()

    #expect(!highDifficulty.needsFocus)
}
#endif
