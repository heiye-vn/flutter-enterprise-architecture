# Flutter 企业级全栈架构与跨端开发知识库 (flutter-enterprise-architecture)

<p align="center">
  <img src="./assets/flutter_logo.png" alt="Flutter Logo" />
</p>


<p align="center">
  <strong>面向工业级生产实践的 Flutter & Dart 系统化学习、架构设计与工程化沉淀</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.47.x-02569B?style=flat-square&logo=flutter" alt="Flutter Version" />
  <img src="https://img.shields.io/badge/Dart-3.13.x-0175C2?style=flat-square&logo=dart" alt="Dart Version" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture%20%7C%20DDD-brightgreen?style=flat-square" alt="Architecture" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License" />
</p>

---

## 📖 项目简介

本项目用于系统化记录 **Flutter & Dart 企业级全栈开发** 的学习历程与工程架构实践。不同于浅尝辄止的 Demo 堆砌，本项目立足于真实工业级业务场景，从**语言底层**、**渲染机制**、**架构分层（Clean Architecture / DDD）**、**高阶状态管理**、**全平台响应式适配**到**CI/CD 自动化构建**，构建完整的端到端知识网络与实战能力。

当前仓库内置了两套完整、互补的高质量教程专栏，覆盖了从前端工程师心智迁移到工业级架构深水区的全部知识链。

---

## 🛠️ 推荐技术基准与开发环境

- **Flutter SDK**: `3.47.x` 或更高稳定版 (Channel `stable`)
- **Dart SDK**: `3.13.x` 或更高版本
- **开发工具推荐**:
  - **IDE**: [VS Code](https://code.visualstudio.com/) 或 [Android Studio Ladybug+](https://developer.android.com/studio)
  - **VS Code 推荐插件**:
    - `Flutter` / `Dart` (Official)
    - `Flutter Riverpod Snippets` / `bloc` (状态管理辅助)
    - `Awesome Flutter Snippets` (提高编码效率)
    - `Error Lens` (行内即时语法高亮)
    - `Pubspec Assist` (便捷依赖查找与注入)
- **核心依赖生态版本参考**:
  - 路由管理: `go_router: ^18.0.0`
  - 状态管理: `flutter_riverpod: ^3.5.0` / `flutter_bloc: ^8.1.0`
  - 网络通信: `dio: ^5.7.0`
  - 依赖注入: `get_it: ^7.7.0`
  - 数据模型与序列化: `freezed: ^2.5.0` / `json_serializable: ^6.8.0`

---

## 📂 仓库目录规划

```text
flutter-enterprise-architecture/
├── docs/                               # 核心技术文档体系
│   ├── tutorial_01/                    # 专栏一：面向前端开发者的企业级开发体系
│   ├── tutorial_02/                    # 专栏二：企业级跨端开发架构全景指南
│   └── guides/                         # 操作手册（真机调试等实践指引）
├── project/                            # 配套实战工程（可放多个 App）
│   └── scjh_app/                       # 企业级 Flutter App 骨架，可运行
├── LICENSE                             # MIT 开源协议
├── README.md                           # 仓库总览与导航指引
└── .gitignore                          # 规范化 Git 忽略配置
```

---

## 🤝 学习交流与贡献

欢迎提 Issue 讨论架构方案，或提交 Pull Request 完善文档细节与示例代码！

1. Fork 本仓库
2. 新建特性分支 (`git checkout -b feat/new-topic`)
3. 提交代码变更 (`git commit -m 'feat: 新增 xx 专题内容'`)
4. 推送至远程分支 (`git push origin feat/new-topic`)
5. 发起 Pull Request

---

## 📄 License

本项目基于 [MIT 协议](./LICENSE) 开源。
