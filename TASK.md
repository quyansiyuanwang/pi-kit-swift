# TASK — PiKit：PiAI + PiAgentCore 的组合层

你是本仓库的开发 agent。目标是提供一个**供应用直接依赖的组合层**，把 `PiAI`（provider/类型）
与 `PiAgentCore`（Agent 循环）装配成开箱可用的运行时，避免每个应用重复写样板。

本包依赖（已发布）：
- `https://github.com/quyansiyuanwang/pi-ai-swift.git`（产品 `PiAI`，v0.1.0）
- `https://github.com/quyansiyuanwang/pi-agent-swift.git`（产品 `PiAgentCore`，v0.1.0）

## 需要实现

1. **统一导出**：`@_exported import PiAI` 与 `@_exported import PiAgentCore`，应用只需 `import PiKit`。

2. **配置与装配**
   ```swift
   public struct AgentConfiguration: Sendable {
       public var baseURL: String
       public var apiKey: String
       public var model: String
       public var provider: String        // 默认 "deepseek"
       public var contextWindow: Int      // 默认 128_000
       public var maxTokens: Int?
       public var temperature: Double?
       public var systemPrompt: String
       public var tools: [any AgentTool]
       public init(...)                   // 提供带默认值的便利初始化
   }

   public enum AgentKit {
       public static func model(_ c: AgentConfiguration) -> Model
       public static func agent(_ c: AgentConfiguration) -> PiAgentCore.Agent
   }
   ```
   - `model` 构造 `PiAI.Model`（api = "openai-completions"）。
   - `agent` 用 `PiAgentCore.AgentOptions`，provider 用下面的 `ConfiguredProvider`，apiKey 透传。

3. **`ConfiguredProvider`**：包装任意 `PiAI.ChatProvider`，把 `temperature` / `maxTokens`
   注入每次 `ChatOptions`（因为 `AgentOptions` 只透传 apiKey）。

4. **事件/文本工具**
   ```swift
   public enum AgentText {
       public static func text(of blocks: [ContentBlock]) -> String
       public static func finalAnswer(in messages: [Message]) -> String
       public static func describe(_ value: JSONValue) -> String   // 空对象返回 ""
   }
   ```

5. **`FunctionTool`**：用 JSON schema + 闭包构造 `AgentTool`，省去每个工具写样板：
   ```swift
   public struct FunctionTool: AgentTool {
       public init(
           name: String,
           description: String,
           parametersJSONSchema: JSONValue,
           execute: @escaping @Sendable (ToolCall, (@Sendable (ToolResult) -> Void)?) async throws -> ToolResult
       )
   }
   ```
   注意 `Sendable` 约束；闭包要能安全跨并发域。

## 工程要求
- SwiftPM，`swift-tools-version:6.0`，macOS 13+ / iOS 16+。
- Swift 6 严格并发零警告（含 `-Xswiftc -warnings-as-errors`）。
- 测试：用假 `ChatProvider` 覆盖 `AgentKit.makeAgent` 的装配、`ConfiguredProvider` 的参数注入、
  `AgentText` 三个函数、`FunctionTool` 的执行与 schema 透传。
- `README.md`（快速开始：用 6 行代码从配置到 `agent.prompt`）、`LICENSE`(MIT)、
  `ATTRIBUTION.md`、`docs/PORTING.md`（说明本包是组合层，非上游移植）、
  `.github/workflows/ci.yml`（macOS，`swift build && swift test`，warnings-as-errors）。

## Definition of Done
- [ ] `swift build && swift test` 全绿、零警告
- [ ] 公共 API 与上文一致，README 有完整最小示例
- [ ] `.tmp/` 与上游 `.ts` 不提交
- [ ] 提交清晰 commit；**不要**创建 git tag（由我统一处理）

完成后用中文汇报：新增文件、测试通过数量、公共 API 摘要、下一步。
