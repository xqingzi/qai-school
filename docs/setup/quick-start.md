# QAI 学习助手 - 快速开始

## 📋 前置条件检查清单

开始之前，请确认：

- [ ] **Mac 电脑**（MacBook/Air/Pro/iMac/mini）
- [ ] **macOS Sonoma 14.0+**
- [ ] **至少 50GB 可用磁盘空间**
- [ ] **稳定的网络连接**（下载 Xcode）
- [ ] **Apple ID**（免费，用于 Xcode 签名）

---

## 🚀 5 分钟快速搭建

### 步骤 1：安装 Xcode（15-30 分钟）

```bash
# 方式一：App Store（推荐）
# 1. 打开 App Store
# 2. 搜索 "Xcode"
# 3. 点击"获取"
# 4. 等待下载（约 15GB）

# 方式二：命令行检查版本
xcodebuild -version
```

### 步骤 2：创建项目（2 分钟）

1. 打开 Xcode
2. **Create New Project** → **iOS** → **App**
3. 填写：
   - Product Name: `QAISchool`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **SwiftData**
4. 保存到：`~/Documents/Projects/QAISchool/`

### 步骤 3：运行 Hello World（1 分钟）

1. 选择设备：**iPad Pro (12.9-inch)**
2. 点击 ▶️ Run
3. 看到模拟器启动？✅ 成功！

### 步骤 4：配置权限（1 分钟）

编辑 `Info.plist`，添加：

```xml
<key>NSCameraUsageDescription</key>
<string>需要使用相机拍摄错题照片</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>需要从相册选择错题照片</string>
```

### 步骤 5：集成到 Git（1 分钟）

```bash
# 进入你的项目目录
cd /Users/xuqingzi/Documents/vcs/github/qai-school

# 复制 Xcode 项目
cp -r ~/Documents/Projects/QAISchool/* .

# 提交
git add .
git commit -m "feat: 初始化 Xcode 项目"
```

---

## 📚 关键文件结构

```
QAISchool/
├── QAISchoolApp.swift          # 🎯 App 入口（从这里开始）
├── ContentView.swift           # 📱 主视图
├── QAISchool.xcdatamodeld/     # 💾 数据模型
└── Info.plist                  # ⚙️ 应用配置
```

---

## 🎓 Swift 速查（TS 开发者）

```swift
// 变量声明
let name = "张三"           // 常量（类似 TS const）
var age = 10                // 变量（类似 TS let）

// 可选类型（类似 TS | null）
var middleName: String? = nil

// 解包（类似 TS 的 ??）
let displayName = middleName ?? "无"

// 数组操作
let numbers = [1, 2, 3]
let doubled = numbers.map { $0 * 2 }  // $0 是当前元素

// 异步函数（和 TS 完全一样！）
func fetchData() async throws -> String {
    // ...
}

// 调用
let result = try await fetchData()
```

---

## 🧪 测试环境

创建一个测试视图，验证环境配置：

```swift
// ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("✅ 开发环境配置成功！")
                .font(.title)

            Text("QAI 学习助手")
                .font(.headline)
        }
    }
}

#Preview {
    ContentView()
}
```

运行后看到绿色对勾？环境就 OK 了！

---

## 📖 推荐学习顺序

### 第 1 天（2-3 小时）
1. 完成 Xcode 安装
2. 创建第一个项目
3. 运行 Hello World
4. 熟悉 Xcode 界面

### 第 2-3 天（4-6 小时）
1. 学习 Swift 基础语法
   - 变量和常量
   - 可选类型
   - 函数和闭包
   - 集合类型
2. 学习 SwiftUI 基础
   - Text, Image, Button
   - VStack, HStack
   - List
   - @State 状态管理

### 第 4-5 天（4-6 小时）
1. 学习 SwiftData
   - @Model 宏
   - @Query 查询
   - @Environment context
2. 学习异步编程
   - async/await
   - 错误处理
   - URLSession 网络请求

### 第 6-7 天（开始开发）
1. 创建数据模型
2. 实现第一个功能
3. 遇到问题查文档/问 AI

---

## 🆘 常见问题

### Q: Xcode 下载太慢？
A: 夜间下载，或从 Apple Developer 网站下载 `.xip` 文件

### Q: 模拟器启动慢？
A: 首次启动需要 1-2 分钟，正常。可以保持模拟器开启。

### Q: 编译错误？
A: 尝试：
```bash
# 在 Xcode 菜单
Product → Clean Build Folder (⇧⌘K)
```

### Q: Swift 和 TypeScript 差异大吗？
A: 不大！async/await 完全一样，类型系统相似，1 周就能上手。

### Q: 需要买 Apple 开发者账号吗？
A: 个人开发不需要，免费 Apple ID 即可。

---

## 📞 获取帮助

- **文档**：查阅 `docs/design/technology-stack.md`
- **官方文档**：https://swift.org/documentation/
- **Stack Overflow**：搜索 "SwiftUI [你的问题]"
- **AI 助手**：让 Claude/ChatGPT 解释 Swift 代码

---

## ✅ 验证清单

完成以下检查：

- [ ] Xcode 15.0+ 已安装
- [ ] 能运行模拟器
- [ ] 中文显示正常
- [ ] 配置了相机和照片库权限
- [ ] 项目已提交到 Git

全部通过？🎉 开始开发吧！

---

## 下一步

环境搭建完成后，参考：
1. `docs/plans/implementation-plan.md` - 完整开发计划
2. `docs/design/ai-service-architecture.md` - AI 服务设计
3. 开始第一周任务：搭建项目基础 + 数据模型

**记住**：边做边学，不要等完全学会 Swift 再开始！
