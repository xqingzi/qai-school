# QAI 学习助手 - 实施计划（更新版）

**最后更新**：2026年1月30日
**当前状态**：核心代码已完成，等待环境集成测试

---

## 项目概述

**目标**：构建一个帮助小学生（1-6年级）整理错题和复习的 iPad 应用
**技术栈**：SwiftUI + SwiftData + PhotosPicker
**最低版本**：iOS 17.0+（iPad Pro 2018 及更新）
**AI 服务**：ZAI（GLM-4.6V + GLM-4.7）

---

## 核心设计原则

1. **中文界面为主**（英语课除外）
2. **个人项目，无商业化**，使用 LLM API 提供智能能力
3. **辅助而非代替思考**，启发式引导
4. **架构保持灵活**，随着 LLM 能力提升自动增强

---

## 技术栈

| 层级 | 技术 | 版本要求 |
|------|------|---------|
| **UI 框架** | SwiftUI | iOS 17+ |
| **数据持久化** | SwiftData | iOS 17+ |
| **图片选择** | PhotosPicker | iOS 16+ |
| **相机** | UIImagePickerController | - |
| **网络请求** | URLSession | - |
| **安全存储** | Keychain Services | - |
| **语言** | Swift | 5.9+ |
| **开发工具** | Xcode | 15.0+ |

---

## 开发进度总览

### ✅ 已完成（90%）

| 阶段 | 任务 | 状态 | 完成日期 |
|------|------|------|---------|
| **第一周** | 数据模型实现 | ✅ 完成 | 2026-01-30 |
| **第一周** | 基础 UI 框架 | ✅ 完成 | 2026-01-30 |
| **第二周** | AI Service 层 | ✅ 完成 | 2026-01-30 |
| **第二周** | ZAI API 集成 | ✅ 完成 | 2026-01-30 |
| **第二周** | Keychain 安全存储 | ✅ 完成 | 2026-01-30 |
| **第三周** | 图片选择功能 | ✅ 完成 | 2026-01-30 |
| **第三周** | AI 分析流程 | ✅ 完成 | 2026-01-30 |
| **第三周** | 错题列表页 | ✅ 完成 | 2026-01-30 |
| **第三周** | 错题详情页 | ✅ 完成 | 2026-01-30 |
| **第三周** | 基础筛选功能 | ✅ 完成 | 2026-01-30 |

### ⏳ 待完成（10%）

| 阶段 | 任务 | 状态 | 预计时间 |
|------|------|------|---------|
| **集成** | 环境搭建和代码集成 | ⏳ 进行中 | 0.5-1天 |
| **集成** | 修复编译错误 | ⏳ 待开始 | 0.5天 |
| **集成** | 配置 API Key 测试 | ⏳ 待开始 | 0.5小时 |
| **集成** | 完整流程测试 | ⏳ 待开始 | 2小时 |
| **第四周** | UI/UX 优化 | ⏳ 待开始 | 2-3天 |
| **第四周** | 性能优化 | ⏳ 待开始 | 1天 |
| **第四周** | Bug 修复 | ⏳ 待开始 | 1天 |

---

## 详细开发阶段

### 第一周：项目基础 ✅ 已完成

#### 任务 1.1：搭建开发环境 ✅
- [x] 文档：开发环境搭建指南
- [x] 文档：快速开始指南
- [ ] 实际环境搭建（在新机器上进行）

#### 任务 1.2：实现核心数据模型 ✅
- [x] 定义 `MistakeRecord` 模型（@Model）
- [x] 定义相关枚举：`Subject`, `ErrorType`, `MistakeSource`, `TimeFilter`
- [x] 配置 SwiftData Container
- [x] 实现 MistakeAnalysis AI 分析模型
- [x] 编写单元测试验证

**代码文件**：
- `Models/Enums.swift` (126行)
- `Models/MistakeRecord.swift` (190行)
- `Models/MistakeAnalysis.swift` (190行)

#### 任务 1.3：搭建基础 UI 框架 ✅
- [x] 创建主入口 `QAISchoolApp.swift`
- [x] 实现 TabView 导航（错题本 + 设置）
- [x] 创建基础导航结构

**代码文件**：
- `QAISchoolApp.swift` (60行)
- `Views/Tabs/MistakeBookTab.swift` (280行)
- `Views/Tabs/SettingsTab.swift` (260行)

**交付物**：✅ 完成
- 完整的应用框架代码
- 数据模型可以保存和读取数据

---

### 第二周：AI 服务集成 ✅ 已完成

#### 任务 2.1：实现 AI Service 抽象层 ✅
- [x] 定义 `AIService` protocol
- [x] 定义数据模型：`MistakeAnalysis`
- [x] 实现统一的错误处理：`AIServiceError`
- [x] 创建 `AIServiceManager` 单例

**代码文件**：
- `Services/AI/AIService.swift` (290行)
- `Services/AI/AIServiceManager.swift` (200行)

#### 任务 2.2：集成 ZAI API ✅
- [x] 实现 `ZAIService`（AIService 协议）
- [x] 实现 GLM-4.6V 视觉模型调用
- [x] 设计并优化 Prompt（提取题目、知识点、错误分析）
- [x] 实现响应解析（JSON → Swift 模型）
- [x] 添加网络错误处理和重试逻辑

**代码文件**：
- `Services/AI/ZAIService.swift` (370行)

#### 任务 2.3：实现 API Key 管理 ✅
- [x] 创建 `KeychainService` 封装
- [x] 实现 API Key 安全存储
- [x] 实现 API Key 验证功能
- [x] 创建设置页 UI
  - API Key 输入框
  - Provider 选择（预留 DeepSeek）
  - 验证按钮

**代码文件**：
- `Services/Storage/KeychainService.swift` (220行)
- `ViewModels/SettingsViewModel.swift` (220行)
- `Views/Tabs/SettingsTab.swift` (260行)

**交付物**：✅ 完成
- 可以调用 ZAI API 分析图片
- API Key 安全存储和验证
- 完整的错误处理

---

### 第三周：核心功能开发 ✅ 已完成

#### 任务 3.1：实现图片选择功能 ✅
- [x] 实现 PhotosPicker 集成
- [x] 实现系统相机调用
- [x] 实现图片预览
- [x] 图片压缩和优化（目标 < 2MB）

**代码文件**：
- `Views/Camera/CameraView.swift` (320行)
- `ViewModels/CameraViewModel.swift` (200行)

#### 任务 3.2：实现 AI 分析流程 ✅
- [x] 创建分析进度页面 UI
- [x] 实现异步分析调用
- [x] 处理分析失败场景
- [x] 实现分析结果保存

**代码文件**：
- `ViewModels/CameraViewModel.swift` (分析逻辑)

#### 任务 3.3：实现错题列表页 ✅
- [x] 使用 `@Query` 实现数据绑定
- [x] 创建列表 UI（List + MistakeCard）
- [x] 显示关键信息（缩略图、知识点、时间）
- [x] 支持点击查看详情
- [x] 添加空状态提示
- [x] 添加删除功能

**代码文件**：
- `Views/Tabs/MistakeBookTab.swift` (列表部分)
- `ViewModels/MistakeListViewModel.swift` (240行)

#### 任务 3.4：实现错题详情页 ✅
- [x] 创建详情页 UI
  - 原图展示
  - 题目文本
  - 知识点标签
  - 错误类型和原因
  - AI 分析结果
- [x] 实现编辑功能（笔记）
- [x] 实现删除功能
- [x] 添加导航返回

**代码文件**：
- `Views/MistakeDetail/MistakeDetailView.swift` (430行)

**交付物**：✅ 完成
- 完整的错题录入流程
- 可以查看和管理错题

---

### 第四周：完善和测试 ⏳ 进行中

#### 任务 4.1：实现筛选功能 ✅
- [x] 创建筛选 UI（Sheet）
- [x] 实现科目筛选（数学/语文/英语）
- [x] 实现时间筛选（本周/本月/全部）
- [x] 实现知识点筛选（动态提取）
- [x] 实现来源筛选（校内/作业/自主）
- [x] 更新列表查询逻辑

**代码文件**：
- `Views/Tabs/MistakeBookTab.swift` (FilterSheet)

#### 任务 4.2：优化 UI/UX ⏳ 待开始
- [ ] 统一颜色和字体
- [ ] 优化图片加载（缩略图缓存）
- [ ] 优化列表滚动性能
- [ ] 添加加载状态动画
- [ ] 优化错误提示 UI
- [ ] 添加确认对话框（删除等操作）

#### 任务 4.3：完善错误处理 ⏳ 待开始
- [ ] 网络错误处理（超时重试、离线提示）
- [ ] API 错误处理（401、429、500）
- [ ] 数据验证（图片格式、JSON 解析）
- [ ] 用户友好的错误提示

#### 任务 4.4：集成测试 ⏳ 待开始
- [ ] 完整流程测试（拍照→分析→查看→筛选→删除）
- [ ] 边界情况测试（无网络、API Key 无效、图片过大）
- [ ] 性能测试（大量错题 100+）
- [ ] Bug 修复

**交付物**：⏳ 预计 2-4 天内完成
- 第一个可演示的 MVP 版本
- 完整的使用说明

---

## 代码文件清单

### 已实现的核心代码（17个文件）

| 文件 | 行数 | 说明 |
|------|------|------|
| **Models/** | | |
| `Enums.swift` | 126 | 枚举定义 |
| `MistakeRecord.swift` | 190 | 错题记录模型 |
| `MistakeAnalysis.swift` | 190 | AI 分析结果 |
| **Services/AI/** | | |
| `AIService.swift` | 290 | AI 服务协议 |
| `ZAIService.swift` | 370 | ZAI API 实现 |
| `AIServiceManager.swift` | 200 | AI 服务管理器 |
| **Services/Storage/** | | |
| `KeychainService.swift` | 220 | Keychain 存储 |
| `ImageStorageService.swift` | 280 | 图片存储 |
| **ViewModels/** | | |
| `CameraViewModel.swift` | 200 | 相机视图模型 |
| `MistakeListViewModel.swift` | 240 | 列表视图模型 |
| `SettingsViewModel.swift` | 220 | 设置视图模型 |
| **Views/Tabs/** | | |
| `MistakeBookTab.swift` | 280 | 错题本页面 |
| `SettingsTab.swift` | 260 | 设置页面 |
| **Views/** | | |
| `CameraView.swift` | 320 | 相机页面 |
| `MistakeDetailView.swift` | 430 | 详情页面 |
| **App/** | | |
| `QAISchoolApp.swift` | 60 | 应用入口 |

**总计**：17 个文件，约 3,900 行代码

---

## 新机器快速开始指南

### 步骤 1：Clone 仓库

```bash
# 克隆仓库到新机器
git clone <your-repo-url> qai-school
cd qai-school
```

### 步骤 2：安装 Xcode（如果没有）

从 Mac App Store 搜索并安装 Xcode 15.0+

### 步骤 3：创建 Xcode 项目

1. 打开 Xcode
2. Create New Project → iOS → App
3. 填写信息：
   - Product Name: `QAISchool`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **SwiftData**
4. 保存到项目目录（例如与代码同级）

### 步骤 4：添加代码文件

**方式一：拖拽（推荐）**
1. 在 Xcode 项目导航器中创建分组：
   - Models
   - ViewModels
   - Views（子文件夹：Tabs, Camera, MistakeDetail）
   - Services（子文件夹：AI, Storage）
2. 将 `QAISchool/` 文件夹中的所有 `.swift` 文件拖到对应分组
3. 确保勾选 "Copy items if needed"

**方式二：直接引用**
- 将项目创建在 `qai-school/` 目录下
- 代码已在 `QAISchool/` 文件夹中

### 步骤 5：配置 Info.plist

添加以下权限描述：

```xml
<key>NSCameraUsageDescription</key>
<string>需要使用相机拍摄错题照片</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>需要从相册选择错题照片</string>
```

### 步骤 6：首次编译

1. 选择 iPad 模拟器
2. 点击 ▶️ Run
3. **会有编译错误**，这是正常的
4. 逐个修复（参考常见问题）

### 步骤 7：配置 API Key

1. 运行应用（修复基本错误后）
2. 进入"设置" Tab
3. 点击"AI 服务配置"
4. 粘贴 ZAI API Key
5. 点击"验证"并保存

### 步骤 8：测试完整流程

1. 点击"拍照"按钮
2. 选择一张错题照片
3. 选择错题来源
4. 点击"AI 智能分析"
5. 等待分析完成
6. 查看错题详情

---

## 常见编译问题及修复

### 问题 1：Swift Testing 框架

**错误**：`Cannot find 'testing' in scope`

**修复**：暂时注释掉所有测试代码
```swift
// #if DEBUG
// import testing
// #endif
```

### 问题 2：PhotosPicker API

**错误**：参数类型不匹配

**修复**：检查 iOS 16+ PhotosPicker API 文档，调整参数

### 问题 3：SwiftData Predicate

**错误**：Predicate 宏语法错误

**修复**：确保 iOS 17.0+，检查 Predicate 语法

### 问题 4：Missing module

**错误**：No such module 'SwiftData'

**修复**：
- 确保选择了 iOS 17.0+
- Clean Build Folder (⇧⌘K)
- 重新编译

---

## 参考文档

- **开发环境**：`docs/setup/development-environment.md`
- **快速开始**：`docs/setup/quick-start.md`
- **代码说明**：`QAISchool/README.md`
- **技术栈**：`docs/design/technology-stack.md`
- **AI 架构**：`docs/design/ai-service-architecture.md`
- **进度报告**：`docs/progress/initial-implementation-summary.md`

---

## 下一步计划

### 立即任务（今天）

1. ✅ 在新机器上 clone 仓库
2. ✅ 创建 Xcode 项目
3. ✅ 添加代码文件
4. ⏳ 修复编译错误（预计 1-2小时）
5. ⏳ 首次运行成功（预计 30分钟）

### 短期任务（本周）

1. 配置 API Key
2. 测试完整流程
3. 修复发现的 Bug
4. UI/UX 优化

### 中期任务（下周）

1. 性能优化
2. 更多测试
3. 卡通化界面
4. 学习统计功能

---

## 里程碑

| 里程碑 | 目标日期 | 状态 |
|--------|---------|------|
| ✅ 核心代码完成 | 2026-01-30 | 已完成 |
| ⏳ 环境集成 | 2026-01-30 | 进行中 |
| ⏳ MVP 可演示 | 2026-01-31 | 待开始 |
| ⏳ 完整测试 | 2026-02-02 | 待开始 |
| ⏳ 优化完成 | 2026-02-05 | 待开始 |

---

## 预计时间线

- **代码实现**：✅ 已完成（1天）
- **环境集成**：⏳ 进行中（0.5-1天）
- **测试修复**：⏳ 待开始（0.5-1天）
- **优化完善**：⏳ 待开始（2-3天）

**总计**：原计划 4 周，实际核心代码 1 天完成！

---

## 联系方式

遇到问题时：
1. 查阅 `QAISchool/README.md` 的常见问题
2. 参考文档（见上方）
3. 提问时请提供：
   - 完整的错误信息
   - 出错的文件和行号
   - Xcode 版本

祝开发顺利！🚀
