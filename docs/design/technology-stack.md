# 技术栈决策（已确认）

## 核心框架

### ✅ UI 框架：SwiftUI

- **语言**：Swift
- **最低版本**：iOS 17.0+（iPad Pro 2018 及更新完全支持）
- **理由**：
  - 最佳性能和用户体验
  - 原生 API 完整支持
  - 声明式 UI 与 React/React Native 思想类似

### ✅ 图片选择：PhotosPicker

- **API**：`PhotosPicker` (iOS 16+)
- **功能**：
  - 从相册选择照片
  - 多选支持
  - 原生界面体验好
- **相机**：使用系统相机（UIImagePickerController）

### ✅ 数据持久化：SwiftData

- **最低版本**：iOS 17.0+
- **优势**：
  - 与 SwiftUI 无缝集成
  - 类似 ORM 的声明式 API
  - 代码简洁（@Model 宏）

### ✅ 安全存储：Keychain Services

- **用途**：API Key 加密存储
- **API**：原生 Keychain 框架

---

## Swift vs TypeScript 对比

### 相似之处（好消息！）

| TypeScript | Swift | 说明 |
|-----------|-------|------|
| 类型注解 | 类型注解 | `let name: string` vs `let name: String` |
| `interface` | `protocol` | 定义接口/协议 |
| `async/await` | `async/await` | 完全相同的语法！ |
| `try/catch` | `do/catch` | 错误处理 |
| `optional chaining` | `optional chaining` | `user?.address?.city` |
| `map/filter/reduce` | `map/filter/reduce` | 函数式编程 |
| `class` | `class` | OOP |
| `enum` | `enum` | 枚举（Swift 的更强大） |

### 主要差异

**1. 变量声明**

```typescript
// TypeScript
let name: string = "张三";  // 不可变
const age: number = 10;     // 不可变
var score: number = 95;     // 可变（TS 很少用）
```

```swift
// Swift
let name: String = "张三"   // 不可变（类似 TS 的 let）
var age: Int = 10           // 可变（Swift 推荐 let，需要变时才用 var）
```

**2. 可选类型（Optional）**

```typescript
// TypeScript
let name: string | null = null;
```

```swift
// Swift
let name: String? = nil  // ? 表示 Optional

// 解包方式
if let unwrappedName = name {
    print(unwrappedName)
}

// 链式调用
let city = user?.address?.city  // 和 TS 一样！
```

**3. 结构体（Struct）**

```typescript
// TypeScript
interface User {
    name: string;
    age: number;
}

const user: User = { name: "张三", age: 10 };
```

```swift
// Swift（推荐用 struct 而非 class）
struct User {
    let name: String
    let age: Int
}

let user = User(name: "张三", age: 10)
```

**4. 函数定义**

```typescript
// TypeScript
function add(a: number, b: number): number {
    return a + b;
}

const arrow = (a: number, b: number): number => a + b;
```

```swift
// Swift
func add(a: Int, b: Int) -> Int {
    return a + b
}

// 闭包（类似箭头函数）
let arrow = { (a: Int, b: Int) -> Int in
    return a + b
}
```

**5. 集合类型**

```typescript
// TypeScript
const numbers: number[] = [1, 2, 3];
const userMap: Map<string, User> = new Map();
```

```swift
// Swift
let numbers: [Int] = [1, 2, 3]
let userMap: [String: User] = [:]  // 字典语法更简洁
```

---

## 项目结构

```
QAI-School/
├── QAISchoolApp.swift              # App 入口
├── Models/                          # 数据模型
│   ├── MistakeRecord.swift         # 错题记录（@Model）
│   ├── MistakeAnalysis.swift       # 分析结果
│   └── Enums.swift                 # 枚举定义
├── Views/                           # UI 视图
│   ├── MistakeListView.swift       # 错题列表
│   ├── MistakeDetailView.swift     # 错题详情
│   ├── CameraView.swift            # 拍照/选图
│   ├── SettingsView.swift          # 设置页
│   └── Components/                 # 可复用组件
│       ├── MistakeCard.swift
│       └── FilterBar.swift
├── ViewModels/                      # 视图模型
│   ├── CameraViewModel.swift
│   ├── MistakeListViewModel.swift
│   └── SettingsViewModel.swift
├── Services/                        # 业务服务
│   ├── AIService.swift             # AI 服务接口
│   ├── ZAIService.swift            # ZAI 实现
│   ├── DeepSeekService.swift       # DeepSeek 实现
│   ├── KeychainService.swift       # Keychain 封装
│   └── ImageStorageService.swift   # 图片存储
└── Resources/                       # 资源文件
    ├── Assets.xcassets             # 图片资源
    └── Localizable.strings         # 多语言（未来）
```

---

## Swift 快速入门

### 1. 基础语法（30 分钟）

**变量和常量**
```swift
let name = "张三"           // 类型推断
var age = 10
let score: Int = 95         // 显式类型
```

**可选类型**
```swift
var middleName: String? = nil  // 可能没有中间名

if let name = middleName {
    print("中间名是 \(name)")   // 字符串插值
}

// 空合并运算符（类似 TS 的 ??）
let displayName = middleName ?? "无"
```

**集合**
```swift
// 数组
var numbers = [1, 2, 3]
numbers.append(4)
numbers.map { $0 * 2 }        // $0 是第一个参数

// 字典
var user = ["name": "张三", "age": "10"]
user["city"] = "北京"
```

**函数**
```swift
// 简单函数
func greet(name: String) -> String {
    return "你好，\(name)"
}

// 多返回值（tuple）
func getUser() -> (name: String, age: Int) {
    return ("张三", 10)
}

let (name, age) = getUser()
```

### 2. SwiftUI 基础（30 分钟）

**简单视图**
```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("你好，世界")
            .font(.title)
            .padding()
    }
}
```

**状态管理（类似 React useState）**
```swift
struct CounterView: View {
    @State private var count = 0  // 类似 useState

    var body: some View {
        VStack {
            Text("计数: \(count)")
            Button("增加") {
                count += 1
            }
        }
    }
}
```

**列表（类似 map）**
```swift
struct UserListView: View {
    let users = ["张三", "李四", "王五"]

    var body: some View {
        List(users) { user in
            Text(user)
        }
    }
}
```

### 3. SwiftData 基础（20 分钟）

```swift
import SwiftData
import SwiftUI

// 1. 定义模型
@Model
final class MistakeRecord {
    var id: UUID
    var questionText: String
    var subject: Subject
    var createdAt: Date

    init(questionText: String, subject: Subject) {
        self.id = UUID()
        self.questionText = questionText
        self.subject = subject
        self.createdAt = Date()
    }
}

// 2. 在 App 中配置
@main
struct QAISchoolApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([MistakeRecord.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// 3. 在视图中使用
struct MistakeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mistakes: [MistakeRecord]

    var body: some View {
        List(mistakes) { mistake in
            Text(mistake.questionText)
        }
    }
}
```

---

## 开发环境准备

### Xcode 安装

1. 从 Mac App Store 下载 **Xcode**（免费，约 15GB）
2. 安装完成后打开，同意许可协议
3. 安装 additional components（如果提示）

### 创建第一个项目

1. **Create New Project**
2. 选择 **iOS → App**
3. 填写信息：
   - Product Name: `QAISchool`
   - Interface: **SwiftUI**
   - Storage: **SwiftData**
   - Language: **Swift**
4. 保存位置

### 运行项目

1. 选择目标设备（iPad Pro 11-inch 或 iPad Pro 12.9-inch）
2. 点击 ▶️ Run 按钮
3. 模拟器启动，你应该能看到 "Hello, world"

---

## 学习资源

### 官方文档（推荐）

- **Swift Language Guide**: https://swift.org/documentation/
- **SwiftUI Tutorials**: https://developer.apple.com/tutorials/swiftui
- **SwiftData Documentation**: https://developer.apple.com/documentation/swiftdata

### 视频教程

- **SwiftUI for TypeScript Developers**（推荐在 YouTube 搜索）
- **Stanford CS193p**（免费课程，但偏向原生开发者）

### 代码对照学习

把 TypeScript 概念映射到 Swift：

| TypeScript | Swift | 搜索关键词 |
|-----------|-------|-----------|
| `interface` | `protocol` | "Swift protocol tutorial" |
| `type` | `enum` / `struct` | "Swift enum struct" |
| `async/await` | `async/await` | "Swift async await" |
| `Promise` | `async` | "Swift concurrency" |
| `useState` | `@State` | "SwiftUI state" |
| `useEffect` | `onChange` / `onAppear` | "SwiftUI lifecycle" |
| `props` | `init` 参数 | "SwiftUI init parameters" |
| `className` | 不需要（SwiftUI 用视图） | "SwiftUI view modifiers" |

---

## 开发建议

### 1. 渐进式学习

不要试图一次性学会所有 Swift：

- **第 1 周**：基础语法 + SwiftUI 基础 + SwiftData
- **第 2 周**：async/await + 错误处理 + AI 服务集成
- **第 3-4 周**：边做边学，遇到问题查文档

### 2. 利用 AI 辅助

- 让 Claude/ChatGPT 解释 Swift 代码："这段 Swift 代码对应 TypeScript 怎么写？"
- 让 AI 帮你转换概念："用 Swift 实现 React 的 useEffect"

### 3. 实践优先

- 不要看完教程再动手
- 照着文档敲代码，然后修改实验
- MVP 阶段不需要精通，够用就行

### 4. 常见坑

**⚠️ 分号结尾**
```swift
// Swift 不需要分号！
let name = "张三";  // ❌ 多余
let name = "张三"   // ✅
```

**⚠️ 可选类型**
```swift
let name: String? = "张三"
print(name.count)  // ❌ 编译错误，需要解包
print(name!.count) // ✅ 强制解包（危险）
print(name?.count) // ✅ 可选链（推荐）
```

**⚠️ 值类型 vs 引用类型**
```swift
// struct 是值类型（复制）
class User { var name = "张三" }
struct Point { var x = 0 }

let user = User()
user.name = "李四"  // ✅ class 可以修改

let point = Point()
point.x = 1  // ❌ let 的 struct 不能修改
var point2 = Point()
point2.x = 1  // ✅ var 的 struct 可以修改
```

---

## 技术栈总结

| 层级 | 技术 | 说明 |
|------|------|------|
| **UI** | SwiftUI | 声明式，iOS 17+ |
| **数据** | SwiftData | ORM 风格，iOS 17+ |
| **图片** | PhotosPicker | 相册选择，iOS 16+ |
| **相机** | UIImagePickerController | 系统相机 |
| **网络** | URLSession | 原生 HTTP |
| **安全** | Keychain | 加密存储 |
| **语言** | Swift | 现代化，类型安全 |
| **IDE** | Xcode | 免费，功能强大 |

---

## 下一步

确认技术栈后，我们将：
1. 创建 Xcode 项目
2. 搭建基础数据模型
3. 实现第一个可运行的界面

有问题随时问我！Swift 上手其实很快的 🚀
