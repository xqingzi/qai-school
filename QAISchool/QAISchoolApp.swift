//
//  QAISchoolApp.swift
//  QAI 学习助手
//
//  App 入口
//

import SwiftUI
import SwiftData

@main
struct QAISchoolApp: App {
    // MARK: - SwiftData Container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([MistakeRecord.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsCloudSync: false  // 暂不支持云同步
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("无法创建 ModelContainer: \(error)")
        }
    }()

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
        .modelContext(for: MistakeRecord.self)  // 确保 ModelContext 可用
    }
}

// MARK: - 主 TabView
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // 错题本
            MistakeBookTab()
                .tabItem {
                    Label("错题本", systemImage: "book.fill")
                }
                .tag(0)

            // 设置
            SettingsTab()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(1)
        }
        .tint(.blue)
    }
}

// MARK: - 预览
#Preview {
    MainTabView()
}
