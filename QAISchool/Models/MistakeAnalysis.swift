//
//  MistakeAnalysis.swift
//  QAI 学习助手
//
//  AI 分析结果数据模型
//

import Foundation

// MARK: - AI 分析结果
struct MistakeAnalysis: Codable, Identifiable {
    let id: UUID
    let questionText: String          // 题目文本
    let subject: Subject               // 科目
    let knowledgePoints: [String]      // 知识点数组
    let errorType: ErrorType           // 错误类型
    let errorReason: String            // 错误原因
    let difficultyLevel: Int           // 难度 1-5
    let hints: [String]                // 渐进式提示
    let suggestedAnswer: String?       // 参考答案（可选）
    let source: MistakeSource          // 错题来源
    let analyzedAt: Date               // 分析时间

    init(
        id: UUID = UUID(),
        questionText: String,
        subject: Subject,
        knowledgePoints: [String],
        errorType: ErrorType,
        errorReason: String,
        difficultyLevel: Int,
        hints: [String],
        suggestedAnswer: String? = nil,
        source: MistakeSource,
        analyzedAt: Date = Date()
    ) {
        // 验证难度等级
        precondition(difficultyLevel >= 1 && difficultyLevel <= 5, "难度等级必须在 1-5 之间")

        self.id = id
        self.questionText = questionText
        self.subject = subject
        self.knowledgePoints = knowledgePoints
        self.errorType = errorType
        self.errorReason = errorReason
        self.difficultyLevel = difficultyLevel
        self.hints = hints
        self.suggestedAnswer = suggestedAnswer
        self.source = source
        self.analyzedAt = analyzedAt
    }

    /// 转换为错题记录
    func toMistakeRecord(imageFileName: String) -> MistakeRecord {
        return MistakeRecord(
            id: id,
            imageFileName: imageFileName,
            questionText: questionText,
            subject: subject,
            knowledgePoints: knowledgePoints,
            errorType: errorType,
            errorReason: errorReason,
            difficultyLevel: difficultyLevel,
            hints: hints,
            suggestedAnswer: suggestedAnswer,
            source: source,
            isMastered: false,
            personalNotes: nil,
            createdAt: analyzedAt,
            updatedAt: analyzedAt
        )
    }
}

// MARK: - 原始 AI 响应模型（用于 JSON 解析）
private struct RawMistakeAnalysis: Codable {
    let questionText: String
    let subject: String
    let knowledgePoints: [String]
    let errorType: String
    let errorReason: String
    let difficultyLevel: Int
    let hints: [String]
    let suggestedAnswer: String?
}

// MARK: - AI 分析响应扩展
extension MistakeAnalysis {
    /// 从 JSON 字符串创建分析结果
    static func from(json: String) throws -> Self {
        let data = json.data(using: .utf8) ?? Data()

        // 尝试直接解析
        var rawAnalysis: RawMistakeAnalysis

        do {
            rawAnalysis = try JSONDecoder().decode(RawMistakeAnalysis.self, from: data)
        } catch {
            // 尝试清理 markdown 代码块标记
            let cleaned = cleanMarkdownCodeBlock(json)
            let cleanedData = cleaned.data(using: .utf8) ?? Data()
            rawAnalysis = try JSONDecoder().decode(RawMistakeAnalysis.self, from: cleanedData)
        }

        // 解析枚举
        guard let subject = Subject(rawValue: rawAnalysis.subject) else {
            throw AIServiceError.parseFailed
        }

        guard let errorType = ErrorType(rawValue: rawAnalysis.errorType) else {
            throw AIServiceError.parseFailed
        }

        // 验证难度等级
        guard (1...5).contains(rawAnalysis.difficultyLevel) else {
            throw AIServiceError.parseFailed
        }

        return MistakeAnalysis(
            questionText: rawAnalysis.questionText,
            subject: subject,
            knowledgePoints: rawAnalysis.knowledgePoints,
            errorType: errorType,
            errorReason: rawAnalysis.errorReason,
            difficultyLevel: rawAnalysis.difficultyLevel,
            hints: rawAnalysis.hints,
            suggestedAnswer: rawAnalysis.suggestedAnswer,
            source: .homework // 默认值，后续可从参数传入
        )
    }

    /// 清理 markdown 代码块标记
    private static func cleanMarkdownCodeBlock(_ text: String) -> String {
        text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - 单元测试
#if DEBUG
import testing

@Test
func testMistakeAnalysisValidation() {
    // 测试难度等级验证
    #expect(throws: FatalError.self) {
        MistakeAnalysis(
            questionText: "测试",
            subject: .math,
            knowledgePoints: ["加法"],
            errorType: .calculation,
            errorReason: "测试原因",
            difficultyLevel: 6,  // 无效
            hints: ["提示1"],
            source: .homework
        )
    }
}

@Test
func testMistakeAnalysisFromJSON() throws {
    let json = """
    {
        "questionText": "1 + 1 = ?",
        "subject": "数学",
        "knowledgePoints": ["加法"],
        "errorType": "计算错误",
        "errorReason": "粗心",
        "difficultyLevel": 1,
        "hints": ["再算一次"],
        "suggestedAnswer": null
    }
    """

    let analysis = try MistakeAnalysis.from(json: json)

    #expect(analysis.questionText == "1 + 1 = ?")
    #expect(analysis.subject == .math)
    #expect(analysis.knowledgePoints == ["加法"])
    #expect(analysis.errorType == .calculation)
}

@Test
func testMarkdownCodeBlockCleaning() {
    let input = """
    ```json
    {
        "questionText": "测试"
    }
    ```
    """

    let cleaned = MistakeAnalysis.cleanMarkdownCodeBlock(input)

    #expect(!cleaned.contains("```"))
    #expect(cleaned.contains("{"))
}
#endif
