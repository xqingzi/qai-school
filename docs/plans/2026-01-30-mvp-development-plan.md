# MVP 开发计划

## 决策摘要

通过 brainstorming 讨论，明确了 MVP 的核心决策：

### 核心演示场景
**完整流程：拍照 → AI分析 → 查看错题**
- 目标：端到端验证核心价值
- 优先级：能尽快让用户看到应用价值并收集反馈

### AI 功能深度
**完整 AI 分析（OCR + LLM）**
- 使用 LLM API 完成图片识别和内容分析
- 提取：题目文本、知识点、错误类型、错误原因
- 依赖外部服务，有 API 调用成本

### 数据持久化
**完整本地数据库**
- 使用 SwiftData 或 Core Data
- 支持完整的增删改查操作
- 可离线查看已保存的错题

### UI 界面范围
**核心页面 + 设置页**
- 首页（错题列表）
- 拍照页
- 详情页
- 简单筛选功能
- 设置页（API Key 配置）
- 界面风格：简洁实用，暂不追求卡通化

---

## 架构设计建议

### 1. AI Service 层设计

**目标**：支持多个 LLM provider，方便切换和测试

```swift
// 统一的 AI 服务接口
protocol AIService {
    func analyzeMistake(image: UIImage) async throws -> MistakeAnalysis
}

// 可配置的 provider
enum AIProvider {
    case zai
    case deepseek
    case openai  // 未来扩展
}
```

**存储策略**：
- API Key 使用 iOS Keychain 安全存储
- 在设置页提供 API Key 配置界面

### 2. 数据模型设计

**结构化存储 AI 分析结果**（而非纯文本）：

```swift
struct MistakeAnalysis: Codable {
    let id: UUID
    let originalImage: Data
    let questionText: String
    let subject: Subject  // 数学/语文/英语
    let knowledgePoints: [String]  // ["两位数乘法", "进位规则"]
    let errorType: ErrorType  // 计算错误/概念不清/审题错误
    let difficultyLevel: Int  // 1-5
    let source: MistakeSource  // 校内练习/家庭作业/自主练习
    let hints: [String]  // 渐进式提示
    let createdAt: Date
}
```

**设计考虑**：
- 字段设计考虑未来 LLM 能力提升时的扩展性
- 支持"渐进式提示"功能（Scaffolding）
- 预留更多细粒度字段（如错误步骤分析）

### 3. 交互设计原则

**辅助而非代替思考**：

- **多级提示系统**：
  - Level 1: 提示方向（"这道题考查的是..."）
  - Level 2: 提示步骤（"你可以试着先..."）
  - Level 3: 部分解答
  - Level 4: 完整讲解

- **重做错题模式**：
  - 先让学生尝试作答
  - 根据作答情况提供相应级别的提示
  - 避免提供"直接抄答案"的快捷方式

- **AI Prompt 策略**：
  ```
  错误示范："答案是 A，因为..."
  正确示范："这道题的关键在于理解...你可以试着：1)先读题目 2)找出..."
  ```

### 4. 隐私和安全考虑

- **照片默认本地存储**，发送到 LLM API 时：
  - 明确告知用户哪些数据会发送
  - 考虑敏感信息脱敏（学生姓名、学号等）

- **API Key 安全**：
  - 使用 Keychain 存储
  - 不在代码中硬编码

### 5. 多语言准备

即使当前只支持中文，建议建立统一的多语言支持结构：
- 使用 `Localizable.strings`
- 通过"科目"字段支持英语课的英文 UI 元素
- 为未来扩展做准备

---

## MVP 开发优先级

### P0 - 核心功能（必须完成）
1. **项目搭建**
   - iOS 项目初始化（SwiftUI + SwiftData）
   - 基础导航结构

2. **数据模型**
   - MistakeAnalysis 核心数据模型
   - SwiftData 数据库配置
   - 基础增删改查

3. **AI 服务集成**
   - AI Service 接口设计
   - ZAI/DeepSeek API 集成
   - OCR + 文本分析实现
   - API Key 配置和存储

4. **核心页面**
   - 拍照页：相机集成、图片选择
   - 分析页：显示 AI 分析进度和结果
   - 列表页：显示所有错题
   - 详情页：查看单条错题的完整信息

### P1 - 重要功能（时间允许）
5. **筛选和搜索**
   - 按科目筛选
   - 按知识点筛选
   - 按时间筛选
   - 搜索功能

6. **错题编辑**
   - 修改 AI 分析结果
   - 添加个人笔记
   - 标记"已掌握"

### P2 - 增强功能（后续迭代）
7. **复习模式**
   - 重做错题
   - 渐进式提示系统

8. **学习统计**
   - 知识点掌握度可视化
   - 错题趋势

---

## 技术栈建议

### 核心框架
- **SwiftUI**: 现代 UI 框架
- **SwiftData**: iOS 17+ 数据持久化
- **Vision**: iOS 原生 OCR（可选，也可用 LLM 的 OCR 能力）

### AI 集成
- **URLSession**: HTTP 请求
- **Async/Await**: 异步处理

### 安全存储
- **Keychain**: API Key 存储

---

## 时间线估算

### 第一周：项目基础
- Xcode 项目搭建
- 数据模型设计和实现
- SwiftData 配置

### 第二周：AI 服务
- AI Service 层实现
- API 集成（ZAI/DeepSeek）
- Prompt 调试和优化

### 第三周：核心页面
- 拍照页实现
- 分析流程实现
- 列表和详情页

### 第四周：完善和测试
- 设置页（API Key 配置）
- 筛选功能
- Bug 修复和优化

---

## 下一步

确认本设计后，将：
1. 创建详细的实现计划（implementation plan）
2. 使用 Git Worktree 建立隔离的开发环境
3. 开始第一周的开发任务
