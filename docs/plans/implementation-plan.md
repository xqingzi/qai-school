# QAI 学习助手 - 实施计划

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

## AI 服务集成

### ZAI API 配置

**模型选择**：
- **GLM-4.6V**（`glm-4v`）：多模态视觉模型，用于图片识别和分析
- **GLM-4.7**（`glm-4-plus` 或 `glm-4-air`）：文本模型，备用方案

**API 端点**：
```
Base URL: https://open.bigmodel.cn/api/paas/v4/chat/completions
```

**认证方式**：
```
Authorization: Bearer <your-api-key>
```

**使用策略**：
1. 图片分析优先使用 GLM-4.6V（视觉能力）
2. 如果只需要文本处理（如生成练习题），使用 GLM-4.7
3. API Key 由用户在设置页配置，使用 Keychain 加密存储

---

## 开发阶段

### 第一周：项目基础（1月30日 - 2月5日）

#### 任务 1.1：搭建开发环境
- [ ] 安装 Xcode 15.0+
- [ ] 创建 iOS 项目（SwiftUI + SwiftData）
- [ ] 配置项目结构和文件组织
- [ ] 运行第一个 Hello World

#### 任务 1.2：实现核心数据模型
- [ ] 定义 `MistakeRecord` 模型（@Model）
- [ ] 定义相关枚举：`Subject`, `ErrorType`, `MistakeSource`
- [ ] 配置 SwiftData Container
- [ ] 实现基础 CRUD 操作
- [ ] 编写单元测试验证数据持久化

#### 任务 1.3：搭建基础 UI 框架
- [ ] 创建主入口 `QAISchoolApp.swift`
- [ ] 实现 TabView 导航（错题本 + 设置）
- [ ] 创建基础导航结构
- [ ] 配置应用图标和基础资源

**交付物**：
- 可运行的基础应用框架
- 数据模型可以保存和读取数据

---

### 第二周：AI 服务集成（2月6日 - 2月12日）

#### 任务 2.1：实现 AI Service 抽象层
- [ ] 定义 `AIService` protocol
- [ ] 定义数据模型：`MistakeAnalysis`
- [ ] 实现统一的错误处理：`AIServiceError`
- [ ] 创建 `AIServiceManager` 单例

#### 任务 2.2：集成 ZAI API
- [ ] 实现 `ZAIService`（AIService 协议）
- [ ] 实现 GLM-4.6V 视觉模型调用
- [ ] 设计并优化 Prompt（提取题目、知识点、错误分析）
- [ ] 实现响应解析（JSON → Swift 模型）
- [ ] 添加网络错误处理和重试逻辑
- [ ] 编写测试验证 API 调用

#### 任务 2.3：实现 API Key 管理
- [ ] 创建 `KeychainService` 封装
- [ ] 实现 API Key 安全存储
- [ ] 实现 API Key 验证功能
- [ ] 创建设置页 UI
  - API Key 输入框
  - Provider 选择（预留 DeepSeek）
  - 验证按钮
- [ ] 添加用户友好的错误提示

**交付物**：
- 可以调用 ZAI API 分析图片
- API Key 安全存储和验证
- 完整的错误处理

---

### 第三周：核心功能开发（2月13日 - 2月19日）

#### 任务 3.1：实现图片选择功能
- [ ] 实现 PhotosPicker 集成
  - 导入 PhotosUI 框架
  - 创建图片选择器 UI
  - 处理选择结果
- [ ] 实现系统相机调用
  - 配置 Info.plist 权限（相机、照片库）
  - 集成 UIImagePickerController
  - 处理拍摄结果
- [ ] 实现图片预览
  - 显示选中的图片
  - 支持重新选择
  - 图片压缩和优化（目标 < 2MB）

#### 任务 3.2：实现 AI 分析流程
- [ ] 创建分析进度页面 UI
  - Loading 动画
  - 进度文本提示
- [ ] 实现异步分析调用
  - 调用 AIServiceManager
  - 处理成功/失败场景
- [ ] 实现分析结果保存
  - 转换为 MistakeRecord
  - 保存到 SwiftData
  - 处理保存失败
- [ ] 实现页面跳转
  - 分析成功 → 详情页
  - 分析失败 → 错误提示

#### 任务 3.3：实现错题列表页
- [ ] 使用 `@Query` 实现数据绑定
- [ ] 创建列表 UI（List + MistakeCard）
- [ ] 显示关键信息
  - 缩略图
  - 题目文本（预览）
  - 知识点标签
  - 时间
- [ ] 实现点击查看详情
- [ ] 添加空状态提示
- [ ] 实现下拉刷新
- [ ] 添加删除功能（滑动删除）

#### 任务 3.4：实现错题详情页
- [ ] 创建详情页 UI
  - 原图展示
  - 题目文本
  - 知识点标签（可点击筛选）
  - 错误类型和原因
  - AI 分析结果
- [ ] 实现编辑功能
  - 修改题目文本
  - 添加个人笔记
  - 标记"已掌握"/"需重点复习"
- [ ] 实现删除功能
- [ ] 添加导航返回

**交付物**：
- 完整的错题录入流程
- 可以查看和管理错题

---

### 第四周：完善和测试（2月20日 - 2月26日）

#### 任务 4.1：实现筛选功能
- [ ] 创建筛选 UI（Sheet 或侧边栏）
- [ ] 实现科目筛选（数学/语文/英语）
- [ ] 实现时间筛选（本周/本月/全部）
- [ ] 实现知识点筛选（动态提取）
- [ ] 实现来源筛选（校内/作业/自主）
- [ ] 更新列表查询逻辑
- [ ] 显示当前筛选条件
- [ ] 支持清除筛选

#### 任务 4.2：优化 UI/UX
- [ ] 统一颜色和字体
- [ ] 优化图片加载（缩略图缓存）
- [ ] 优化列表滚动性能
- [ ] 添加加载状态动画
- [ ] 优化错误提示 UI
- [ ] 添加确认对话框（删除等操作）

#### 任务 4.3：完善错误处理
- [ ] 网络错误处理
  - 超时重试
  - 离线提示
- [ ] API 错误处理
  - 401 无效 Key
  - 429 限流
  - 500 服务器错误
- [ ] 数据验证
  - 图片格式检查
  - JSON 解析失败处理
- [ ] 用户友好的错误提示

#### 任务 4.4：集成测试
- [ ] 完整流程测试
  - 拍照 → 分析 → 查看 → 筛选 → 删除
- [ ] 边界情况测试
  - 无网络
  - API Key 无效
  - 图片过大
  - 数据库为空
- [ ] 性能测试
  - 大量错题（100+）
  - 大图片
- [ ] Bug 修复

**交付物**：
- 第一个可演示的 MVP 版本
- 完整的使用说明

---

## 数据模型设计

### MistakeRecord（核心实体）

```swift
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
    var source: MistakeSource        // 来源
    var isMastered: Bool             // 是否已掌握
    var personalNotes: String?       // 个人笔记
    var createdAt: Date              // 创建时间
    var updatedAt: Date              // 更新时间
}
```

### 枚举定义

```swift
enum Subject: String, Codable, CaseIterable {
    case math = "数学"
    case chinese = "语文"
    case english = "英语"
}

enum ErrorType: String, Codable, CaseIterable {
    case calculation = "计算错误"
    case concept = "概念不清"
    case careless = "粗心大意"
    case misunderstanding = "审题错误"
    case other = "其他"
}

enum MistakeSource: String, Codable, CaseIterable {
    case school = "校内练习"
    case homework = "家庭作业"
    case selfStudy = "自主练习"
}
```

---

## Prompt 设计

### GLM-4.6V 分析 Prompt

```markdown
你是一个专业的小学教育助手。请分析这张图片中的错题。

**任务**：
1. 识别图片中的题目文本（包括题号）
2. 判断科目（数学/语文/英语）
3. 提取 1-3 个知识点
4. 分析错误类型
5. 分析错误原因（50字以内，中文）
6. 评估难度（1-5，1最简单）
7. 提供 3 个渐进式提示（从方向到具体步骤）

**重要原则**：
- 提示应该是启发式的，不是直接给出答案
- 例如："再读一下题目，看看哪里可能理解错了"
- 而不是："这道题选A"

**输出格式**（纯 JSON）：
```json
{
  "questionText": "题目文本",
  "subject": "数学/语文/英语",
  "knowledgePoints": ["知识点1", "知识点2"],
  "errorType": "计算错误/概念不清/粗心大意/审题错误/其他",
  "errorReason": "错误原因分析（50字以内）",
  "difficultyLevel": 3,
  "hints": [
    "提示1：指出方向",
    "提示2：具体步骤",
    "提示3：关键点提醒"
  ]
}
```

**题目来源**：{source}

只输出 JSON，不要其他内容。
```

---

## API 调用示例

### ZAI GLM-4.6V 请求格式

```swift
POST https://open.bigmodel.cn/api/paas/v4/chat/completions
Authorization: Bearer <your-api-key>
Content-Type: application/json

{
  "model": "glm-4v",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "<prompt内容>"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,<base64编码的图片>"
          }
        }
      ]
    }
  ],
  "temperature": 0.7,
  "max_tokens": 2000
}
```

---

## 文件结构

```
QAISchool/
├── QAISchoolApp.swift              # App 入口
├── Models/                          # 数据模型
│   ├── MistakeRecord.swift         # 错题记录
│   ├── MistakeAnalysis.swift       # AI 分析结果
│   └── Enums.swift                 # 枚举定义
├── Views/                           # UI 视图
│   ├── Tabs/
│   │   ├── MistakeBookTab.swift    # 错题本 Tab
│   │   └── SettingsTab.swift       # 设置 Tab
│   ├── MistakeList/
│   │   ├── MistakeListView.swift   # 列表
│   │   ├── FilterSheet.swift       # 筛选器
│   │   └── MistakeCard.swift       # 错题卡片
│   ├── MistakeDetail/
│   │   ├── MistakeDetailView.swift # 详情
│   │   └── EditNoteSheet.swift     # 编辑笔记
│   ├── Camera/
│   │   ├── CameraView.swift        # 拍照/选图
│   │   ├── ImagePreviewSheet.swift # 图片预览
│   │   └── AnalysisProgressView.swift # 分析进度
│   └── Settings/
│       ├── SettingsView.swift      # 设置主页
│       └── APIKeyConfigView.swift  # API Key 配置
├── ViewModels/                      # 视图模型
│   ├── CameraViewModel.swift
│   ├── MistakeListViewModel.swift
│   └── SettingsViewModel.swift
├── Services/                        # 业务服务
│   ├── AI/
│   │   ├── AIService.swift         # 协议定义
│   │   ├── ZAIService.swift        # ZAI 实现
│   │   └── AIServiceManager.swift  # 管理器
│   ├── Storage/
│   │   ├── KeychainService.swift   # Keychain 封装
│   │   └── ImageStorageService.swift # 图片存储
│   └── API/
│       └── ZAIModels.swift         # ZAI API 模型
└── Resources/                       # 资源
    ├── Assets.xcassets             # 图片资源
    └── Info.plist                  # 配置文件
```

---

## 测试策略

### 单元测试
- [ ] 数据模型 CRUD
- [ ] Keychain 存储和读取
- [ ] 图片存储服务
- [ ] JSON 解析

### 集成测试
- [ ] AI API 调用流程
- [ ] 完整的拍照 → 分析 → 保存流程
- [ ] 筛选功能

### UI 测试
- [ ] 主要用户流程
- [ ] 错误场景

---

## 里程碑

| 日期 | 里程碑 | 状态 |
|------|--------|------|
| 1月30日 | 开发环境搭建完成 | ⏳ 待开始 |
| 2月5日 | 数据模型和基础框架完成 | ⏳ 待开始 |
| 2月12日 | AI 服务集成完成 | ⏳ 待开始 |
| 2月19日 | 核心功能完成 | ⏳ 待开始 |
| 2月26日 | MVP 第一个可演示版本 | ⏳ 待开始 |

---

## 风险和应对

| 风险 | 影响 | 应对策略 |
|------|------|---------|
| Swift 学习曲线 | 开发速度 | 利用 TS 经验，边做边学 |
| ZAI API 变动 | 集成失败 | 使用稳定的 API 版本，做好错误处理 |
| 图片识别效果 | 用户体验 | Prompt 优化，提供手动编辑选项 |
| iOS 17 限制 | 设备覆盖 | 明确最低要求，iPad Pro 2018+ 覆盖率高 |
| SwiftData Bug | 数据丢失 | 做好测试，提供数据导出功能 |

---

## 参考资料

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [ZAI API 文档](https://open.bigmodel.cn/dev/api)
- [PhotosPicker Documentation](https://developer.apple.com/documentation/photokit/photospicker)
- [Swift Language Guide](https://swift.org/documentation/)

---

## 下一步

1. 按照《开发环境搭建指南》配置环境
2. 创建 Xcode 项目
3. 开始第一周的开发任务

有问题随时查阅：
- `docs/design/technology-stack.md` - Swift 学习指南
- `docs/design/ai-service-architecture.md` - AI Service 设计
