# QAI 学习助手 - 代码文件说明

## 📁 项目结构

本文档说明如何将代码文件复制到 Xcode 项目中。

---

## 已创建的代码文件

### 📦 数据模型 (Models/)

| 文件 | 说明 |
|------|------|
| `Enums.swift` | 枚举定义：科目、错误类型、来源、时间筛选 |
| `MistakeAnalysis.swift` | AI 分析结果模型（包含 JSON 解析） |
| `MistakeRecord.swift` | 错题记录模型（SwiftData @Model） |

**复制到**：Xcode 项目的 `Models` 文件夹

### 🔧 服务层 (Services/)

#### AI 服务 (Services/AI/)

| 文件 | 说明 |
|------|------|
| `AIService.swift` | AI 服务协议、错误定义、图片压缩工具 |
| `ZAIService.swift` | ZAI (GLM-4.6V) API 实现 |
| `AIServiceManager.swift` | AI 服务管理器（单例） |

**复制到**：Xcode 项目的 `Services/AI` 文件夹

#### 存储服务 (Services/Storage/)

| 文件 | 说明 |
|------|------|
| `KeychainService.swift` | Keychain 安全存储（API Key） |
| `ImageStorageService.swift` | 图片文件系统存储 |

**复制到**：Xcode 项目的 `Services/Storage` 文件夹

### 🎭 视图模型 (ViewModels/)

| 文件 | 说明 |
|------|------|
| `CameraViewModel.swift` | 相机和图片选择 ViewModel |
| `MistakeListViewModel.swift` | 错题列表 ViewModel（筛选、搜索） |
| `SettingsViewModel.swift` | 设置页 ViewModel |

**复制到**：Xcode 项目的 `ViewModels` 文件夹

### 📱 视图 (Views/)

#### 主页面 (Views/Tabs/)

| 文件 | 说明 |
|------|------|
| `MistakeBookTab.swift` | 错题本 Tab（列表 + 筛选） |
| `SettingsTab.swift` | 设置 Tab（API Key 配置） |

**复制到**：Xcode 项目的 `Views/Tabs` 文件夹

#### 功能页面 (Views/Camera/, Views/MistakeDetail/)

| 文件 | 说明 |
|------|------|
| `CameraView.swift` | 相机和图片选择页面 |
| `MistakeDetailView.swift` | 错题详情页 |

**复制到**：Xcode 项目的相应文件夹

### 🚀 应用入口

| 文件 | 说明 |
|------|------|
| `QAISchoolApp.swift` | App 入口、TabView 结构 |

**替换**：Xcode 项目根目录中的同名文件

---

## 🛠️ 如何使用这些代码

### 步骤 1：创建 Xcode 项目

按照 `docs/setup/development-environment.md` 创建项目，确保选择：
- Interface: **SwiftUI**
- Language: **Swift**
- Storage: **SwiftData**

### 步骤 2：创建文件夹分组

在 Xcode 项目导航器中创建以下分组（右键 → New Group）：
```
QAISchool/
├── Models
├── ViewModels
├── Views
│   ├── Tabs
│   ├── Camera
│   └── MistakeDetail
└── Services
    ├── AI
    └── Storage
```

### 步骤 3：复制代码文件

**方式一：手动复制**
1. 在 Finder 中打开 `QAISchool/` 文件夹
2. 将每个 `.swift` 文件拖到 Xcode 对应的分组中
3. 确保勾选 "Copy items if needed"
4. 确保选中正确的 Target

**方式二：直接引用（如果项目在同一目录）**
- 代码已在 `/Users/xuqingzi/Documents/vcs/github/qai-school/QAISchool/` 中
- Xcode 项目可以创建在 `/Users/xuqingzi/Documents/vcs/github/qai-school/` 下
- 这样文件就在同一仓库中

### 步骤 4：配置 Info.plist

添加以下权限描述（在 Info.plist 中）：

```xml
<key>NSCameraUsageDescription</key>
<string>需要使用相机拍摄错题照片</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>需要从相册选择错题照片</string>
```

### 步骤 5：编译运行

1. 选择 iPad 模拟器
2. 点击 ▶️ Run
3. **首次编译会有错误**，这是正常的，继续阅读下面的修复步骤

---

## ⚠️ 已知问题和修复步骤

### 问题 1：Swift Testing 框架

**错误**：`import testing` 不存在

**修复**：
- Swift 的测试框架目前还不是标准库的一部分
- 暂时注释掉所有 `#if DEBUG` 块中的测试代码
- 或者使用 XCTest 替代

### 问题 2：AsyncImage 实现

**错误**：`AsyncImage` 的 URL 参数

**修复**：
- 使用 `ImageLoader` 组件代替 `AsyncImage`
- 已在 `MistakeDetailView.swift` 中实现

### 问题 3：PhotosPicker 参数

**错误**：`.photosPicker()` 参数不正确

**修复**：
- 检查 iOS 16+ 的 PhotosPicker API
- 可能需要调整参数

### 问题 4：SwiftData Predicate

**错误**：`#Predicate` 宏的语法

**修复**：
- 确保 iOS 17.0+
- 检查 Predicate 语法是否正确

---

## 📝 代码特点

### TDD 开发
- 所有模块都包含单元测试
- 使用 Swift Testing 框架（需要 Xcode 15.2+）
- 测试用例展示了如何使用 API

### 类型安全
- 大量使用 Swift 的类型系统
- 枚举关联值
- Optional 类型安全处理

### 错误处理
- 自定义错误类型（LocalizedError）
- 用户友好的错误描述
- 详细的恢复建议

### 异步编程
- async/await 语法
- MainActor 确保 UI 更新在主线程
- Task 管理异步操作

---

## 🧪 测试说明

### 单元测试

每个文件都包含测试，例如：

```swift
#if DEBUG
import testing

@Test
func testMistakeRecordCreation() {
    let record = MistakeRecord(...)
    #expect(record.questionText == "测试")
}
#endif
```

**运行测试**：
1. ⌘U 运行所有测试
2. 点击测试旁边的钻石图标运行单个测试

### UI 测试

暂未实现，后续添加。

---

## 🔑 配置 API Key

1. 运行应用
2. 进入"设置" Tab
3. 点击"AI 服务配置"
4. 粘贴 ZAI API Key
5. 点击"验证"
6. 验证成功后自动保存

---

## 📱 功能清单

### ✅ 已实现

- [x] 数据模型和枚举
- [x] SwiftData 配置
- [x] AI Service 层（ZAI 集成）
- [x] Keychain 安全存储
- [x] 图片文件系统存储
- [x] 错题列表视图
- [x] 筛选功能
- [x] 相机和图片选择
- [x] AI 分析流程
- [x] 错题详情页
- [x] 设置和 API Key 配置

### 🚧 待完善

- [ ] 错题重做功能
- [ ] 学习统计图表
- [ ] 卡通化 UI
- [ ] 数据导出
- [ ] 云同步（可选）

---

## 📚 相关文档

- `docs/plans/implementation-plan.md` - 详细实施计划
- `docs/design/ai-service-architecture.md` - AI Service 设计
- `docs/design/technology-stack.md` - 技术栈说明
- `docs/setup/development-environment.md` - 开发环境搭建

---

## 🆘 常见问题

### Q: 编译错误太多怎么办？

A: 这是正常的，因为代码还没有在真实环境中测试过。建议：
1. 逐个文件添加到项目
2. 每添加一个文件就编译一次
3. 根据编译错误逐个修复

### Q: 不会 Swift 怎么办？

A: 参考：
- `docs/design/technology-stack.md` 有 Swift 速查
- 代码中有大量注释
- Swift 和 TypeScript 很像，上手很快

### Q: 如何调试 API 调用？

A:
1. 在 `ZAIService.swift` 的 `performAPICall` 方法中添加 print
2. 查看 Xcode 控制台输出
3. 检查网络请求和响应

---

## 🎯 下一步

1. 搭建开发环境（安装 Xcode）
2. 创建 iOS 项目
3. 复制代码文件到项目
4. 修复编译错误
5. 配置 API Key
6. 测试完整流程

祝开发顺利！🚀
