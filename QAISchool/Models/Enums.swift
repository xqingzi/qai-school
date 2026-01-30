//
//  Enums.swift
//  QAI 学习助手
//
//  核心枚举定义
//

import Foundation

// MARK: - 科目
enum Subject: String, Codable, CaseIterable {
    case math = "数学"
    case chinese = "语文"
    case english = "英语"

    /// 图标名称
    var iconName: String {
        switch self {
        case .math: return "figure.calculator"
        case .chinese: return "book.fill"
        case .english: return "textformat.abc"
        }
    }

    /// 颜色
    var color: String {
        switch self {
        case .math: return "blue"
        case .chinese: return "red"
        case .english: return "purple"
        }
    }
}

// MARK: - 错误类型
enum ErrorType: String, Codable, CaseIterable {
    case calculation = "计算错误"
    case concept = "概念不清"
    case careless = "粗心大意"
    case misunderstanding = "审题错误"
    case other = "其他"

    /// 图标名称
    var iconName: String {
        switch self {
        case .calculation: return "calculator"
        case .concept: return "lightbulb"
        case .careless: return "exclamationmark.triangle"
        case .misunderstanding: return "eye"
        case .other: return "questionmark.circle"
        }
    }
}

// MARK: - 错题来源
enum MistakeSource: String, Codable, CaseIterable {
    case school = "校内练习"
    case homework = "家庭作业"
    case selfStudy = "自主练习"

    /// 图标名称
    var iconName: String {
        switch self {
        case .school: return "building.2"
        case .homework: return "house.fill"
        case .selfStudy: return "person.crop.circle"
        }
    }
}

// MARK: - 时间筛选选项
enum TimeFilter: String, Codable, CaseIterable {
    case all = "全部"
    case thisWeek = "本周"
    case thisMonth = "本月"

    /// 计算起始日期
    var startDate: Date? {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .all:
            return nil
        case .thisWeek:
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))
        case .thisMonth:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: now))
        }
    }
}
