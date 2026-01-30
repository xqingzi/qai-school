# 开发环境搭建指南

## 系统要求

在开始之前，请确保你的 Mac 满足以下要求：

### 硬件要求
- **Mac 电脑**：MacBook Pro/Air/Mac mini/iMac 均可
- **内存**：建议 16GB 或以上（8GB 也能用，但运行 Xcode 会卡）
- **磁盘空间**：至少 50GB 可用空间（Xcode + 模拟器）

### 操作系统
- **macOS 版本**：macOS Sonoma 14.0 或更高版本
  - 检查版本：点击左上角  → 关于本机

---

## 第一步：安装 Xcode

### 1.1 下载 Xcode

**方式一：从 Mac App Store 安装（推荐）**

1. 打开 **App Store**（在 Dock 或应用程序文件夹）
2. 搜索 "Xcode"
3. 点击"获取"或"下载"按钮
4. 等待下载完成（约 15GB，需要 30 分钟 - 2 小时，取决于网速）

**方式二：从 Apple Developer 网站下载**

如果 App Store 下载速度慢，可以：
1. 访问 https://developer.apple.com/download/all/
2. 登录 Apple ID（免费）
3. 搜索 "Xcode 15"
4. 下载 `.xip` 文件

### 1.2 安装和配置

下载完成后：

1. **打开 Xcode**
   - 如果从 App Store 安装，会在启动台找到 Xcode 图标
   - 如果下载 `.xip`，双击解压后拖到应用程序文件夹

2. **首次启动**
   - 同意许可协议
   - 输入管理员密码
   - 等待安装额外组件（可能需要 5-10 分钟）

3. **验证安装**
   ```bash
   # 在终端运行，查看 Xcode 版本
   xcodebuild -version
   ```
   应该输出类似：
   ```
   Xcode 15.2
   Build version 15C5002n
   ```

---

## 第二步：安装命令行工具

### 2.1 安装 Xcode Command Line Tools

在终端运行：

```bash
xcode-select --install
```

会弹出一个对话框，点击"安装"。

等待安装完成后，验证：

```bash
gcc --version
```

应该能输出版本信息。

---

## 第三步：创建第一个 iOS 项目

### 3.1 启动 Xcode 并创建新项目

1. **打开 Xcode**
2. 在欢迎界面点击 **"Create New Project"**
   - 或者：菜单栏 → File → New → Project

3. **选择项目模板**
   - 平台选择：**iOS**
   - 模板选择：**App**
   - 点击 "Next"

### 3.2 配置项目信息

填写以下信息：

| 字段 | 值 | 说明 |
|------|-----|------|
| **Product Name** | `QAISchool` | 应用名称 |
| **Team** | 选择你的 Team | 个人开发可以选 None |
| **Organization Identifier** | `com.yourname` | 反转域名 |
| **Bundle Identifier** | 自动生成 | com.yourname.QAISchool |
| **Interface** | **SwiftUI** | ⚠️ 重要：选择 SwiftUI |
| **Language** | **Swift** | ⚠️ 重要：选择 Swift |
| **Storage** | **SwiftData** | ⚠️ 重要：选择 SwiftData |
| **Include Tests** | ✅ 勾选 | 包含单元测试和 UI 测试 |

点击 "Next"

### 3.3 选择保存位置

1. 选择项目保存位置（建议：
   ```
   ~/Documents/Projects/QAISchool/
   ```
2. **取消勾选** "Create Git repository"（我们已有 Git 仓库）
3. 点击 "Create"

### 3.4 项目结构概览

创建后你会看到：

```
QAISchool/
├── QAISchoolApp.swift       # App 入口
├── ContentView.swift        # 示例视图
├── QAISchool.xcdatamodeld/ # SwiftData 数据模型
├── Assets.xcassets         # 图片资源
├── Preview Content/        # SwiftUI Preview
└── QAISchoolTests/         # 测试文件
```

### 3.5 运行第一个应用

1. **选择目标设备**
   - 点击工具栏的设备选择器
   - 选择 **iPad Pro (12.9-inch) (6th generation)** 或更新
   - 或者选择 iPad Pro 11-inch

2. **运行项目**
   - 点击 ▶️ Run 按钮
   - 或按快捷键 `⌘R`

3. **查看模拟器**
   - iPad 模拟器启动
   - 你应该能看到 "Hello, world" 或类似的欢迎界面

🎉 恭喜！你的第一个 iOS 应用运行成功了！

---

## 第四步：配置项目结构

### 4.1 创建文件分组

1. **在 Xcode 左侧项目导航器**，右键点击 `QAISchool` 文件夹
2. 选择 **New Group**，创建以下分组：
   - `Models`
   - `Views`
   - `ViewModels`
   - `Services`
   - `Resources`

### 4.2 删除示例文件

删除 Xcode 自动生成的示例文件（可选）：

```
删除 QAISchool.xcdatamodeld 中的默认 Item 实体
```

### 4.3 配置 Bundle Identifier

1. 点击项目导航器最顶部的 `QAISchool` 项目（蓝色图标）
2. 选择 **TARGETS → QAISchool**
3. 在 **General** 标签页找到 **Identity**
4. 修改 **Bundle Identifier** 为你的实际 ID
   - 例如：`com.yourname.QAISchool`

---

## 第五步：配置应用权限

### 5.1 添加相机和照片库权限

1. 在项目导航器中找到 `QAISchool` 文件夹
2. 找到 `Info.plist` 文件
3. 点击 `+` 号添加以下权限：

| Key | Value | 说明 |
|-----|-------|------|
| **Privacy - Camera Usage Description** | 需要使用相机拍摄错题照片 | 相机权限 |
| **Privacy - Photo Library Add Usage Description** | 需要保存错题照片到相册 | 保存到相册 |
| **Privacy - Photo Library Usage Description** | 需要从相册选择错题照片 | 访问相册 |

### 5.2 配置 iPad 方向

1. 选择 **Deployment Info**
2. **Device Orientation** 取消勾选 **Portrait**（仅保留横屏）
   - 或者保留两者，根据需求

---

## 第六步：安装有用的 Xcode 扩展（可选）

### 6.1 Git 集成

Xcode 自带 Git 支持，无需额外安装。

配置 Git：
```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

### 6.2 代码格式化工具

Swift 官方没有 Prettier，但可以使用：
- **SwiftFormat**：代码格式化
- **SwiftLint**：代码规范检查

安装（需要 Homebrew）：
```bash
# 安装 Homebrew（如果没有）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 SwiftFormat
brew install swiftformat

# 安装 SwiftLint
brew install swiftlint
```

### 6.3 Xcode 插件管理器

推荐使用 **Xcode Command Line Tools** 自带的功能，不需要额外插件。

---

## 第七步：将项目集成到现有 Git 仓库

### 7.1 删除 Xcode 自动创建的 Git（如果有）

```bash
cd ~/Documents/Projects/QAISchool
rm -rf .git
```

### 7.2 关联到现有仓库

```bash
# 进入你的项目目录
cd ~/Documents/Projects/QAISchool

# 添加远程仓库（替换为你的实际地址）
git remote add origin https://github.com/yourusername/qai-school.git

# 或者如果是本地已有仓库
cd /Users/xuqingzi/Documents/vcs/github/qai-school

# 将 Xcode 项目文件复制过来
cp -r ~/Documents/Projects/QAISchool/* .

# 提交
git add .
git commit -m "feat: 初始化 Xcode 项目"
git push origin main
```

### 7.3 创建 .gitignore

在项目根目录创建 `.gitignore`：

```bash
# Xcode
#
# gitignore contributors: remember to update Global/Xcode.gitignore, Objective-C.gitignore & Swift.gitignore

## User settings
xcuserdata/

## compatibility with Xcode 8 and earlier (ignoring not required starting Xcode 9)
*.xcscmblueprint
*.xccheckout

## compatibility with Xcode 3 and earlier (ignoring not required starting Xcode 4)
build/
DerivedData/
*.moved-aside
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3

## Obj-C/Swift specific
*.hmap

## App packaging
*.ipa
*.dSYM.zip
*.dSYM

## Playgrounds
timeline.xctimeline
playground.xcworkspace

# Swift Package Manager
#
# Add this line if you want to avoid checking in source code from Swift Package Manager dependencies.
# Packages/
# Package.pins
# Package.resolved
# *.xcodeproj
#
# Xcode automatically generates this directory with a .xcworkspacedata file and xcuserdata
# hence it is not needed unless you have added a package configuration file to your project
# .swiftpm

.build/

# CocoaPods
#
# We recommend against adding the Pods directory to your .gitignore. However
# you should judge for yourself, the pros and cons are mentioned at:
# https://guides.cocoapods.org/using/using-cocoapods.html#should-i-check-the-pods-directory-into-source-control
#
# Pods/
#
# Add this line if you want to avoid checking in source code from the Xcode workspace
# *.xcworkspace

# Carthage
#
# Add this line if you want to avoid checking in source code from Carthage dependencies.
# Carthage/Checkouts

Carthage/Build/

# Accio dependency management
Dependencies/
.accio/

# fastlane
#
# It is recommended to not store the screenshots in the git repo.
# Instead, use fastlane to re-generate the screenshots whenever they are needed.
# For more information about the recommended setup visit:
# https://docs.fastlane.tools/best-practices/source-control/#source-control

fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Code Injection
#
# After new code Injection tools there's a generated folder /iOSInjectionProject
# https://github.com/johnno1962/injectionforxcode

iOSInjectionProject/

# Mac OS
.DS_Store
```

---

## 第八步：测试开发环境

### 8.1 创建一个测试视图

在 `ContentView.swift` 中修改代码：

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("QAI 学习助手")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("开发环境配置成功！")
                .font(.title3)
                .foregroundColor(.green)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
```

### 8.2 运行测试

按 `⌘R` 运行，你应该能看到中文显示正常。

### 8.3 测试 SwiftData

在 `QAISchoolApp.swift` 中，你应该已经看到：

```swift
.modelContainer(for: Item.self)  // 临时使用 Item
```

暂时保留，后续我们会替换为 `MistakeRecord`。

---

## 常见问题

### Q1: Xcode 下载太慢怎么办？

**解决方案**：
- 使用夜间下载（网速快）
- 从 Apple Developer 网站下载 `.xip` 文件
- 使用第三方下载工具

### Q2: 模拟器启动很慢？

**解决方案**：
- 首次启动需要 1-2 分钟，正常
- 关闭不必要的应用释放内存
- 选择较低版本的模拟器（如 iPad Pro 12.9-inch 6th gen）

### Q3: "Could not find a valid private key" 错误？

**解决方案**：
- 这是签名问题，个人开发可以：
  1. 项目设置 → Signing & Capabilities
  2. 勾选 "Automatically manage signing"
  3. Team 选择你的 Apple ID

### Q4: SwiftData 不可用？

**可能原因**：
- iOS 部署版本低于 iOS 17
- Xcode 版本低于 15.0

**解决方案**：
- 检查 Deployment Target 设置为 iOS 17.0 或更高
- 更新 Xcode 到最新版本

### Q5: 中文显示乱码？

**解决方案**：
- 确保文件编码为 UTF-8
- Xcode 默认使用 UTF-8，应该没问题

---

## 开发工具推荐

### 必备
- **Xcode**：iOS 开发 IDE
- **Simulator**：iOS 模拟器（Xcode 自带）

### 可选但有帮助
- **SF Symbols**：苹果图标浏览器
  ```bash
  # 下载地址
  https://developer.apple.com/sf-symbols/
  ```
- **Ray Fix Regex**：正则表达式测试（Xcode 插件）

### 文档和参考资料
- [Swift 官方文档](https://swift.org/documentation/)
- [SwiftUI 官方教程](https://developer.apple.com/tutorials/swiftui)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

## 下一步

环境搭建完成后：

1. ✅ 运行 `git add .` 和 `git commit` 提交 Xcode 项目文件
2. ✅ 开始第一周的开发任务
3. ✅ 遇到问题随时查阅技术文档

---

## 快速命令参考

```bash
# 查看 Xcode 版本
xcodebuild -version

# 查看可用的模拟器
xcrun simctl list devices

# 清理构建（遇到编译问题时）
# 在 Xcode 菜单：Product → Clean Build Folder (⇧⌘K)

# 重置模拟器（应用异常时）
# 在模拟器菜单：Device → Erase All Content and Settings...

# 打开 Xcode
open -a Xcode

# 从命令行构建项目
xcodebuild -project QAISchool.xcodeproj -scheme QAISchool -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)'
```

---

## 验证清单

完成以下检查，确保环境配置正确：

- [ ] Xcode 15.0+ 已安装
- [ ] Xcode 能正常启动和运行
- [ ] 命令行工具已安装（`gcc --version` 有输出）
- [ ] 创建了 iOS 项目（SwiftUI + SwiftData）
- [ ] 模拟器能运行 "Hello World"
- [ ] 中文显示正常
- [ ] 配置了相机和照片库权限
- [ ] Git 仓库已关联
- [ ] .gitignore 已创建

全部打勾后，你就可以开始开发了！🚀
