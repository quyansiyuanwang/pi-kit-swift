# PiKit

[![CI](https://github.com/quyansiyuanwang/pi-kit-swift/actions/workflows/ci.yml/badge.svg)](https://github.com/quyansiyuanwang/pi-kit-swift/actions/workflows/ci.yml)

The **composition layer** for [`PiAI`](https://github.com/quyansiyuanwang/pi-ai-swift)
and [`PiAgentCore`](https://github.com/quyansiyuanwang/pi-agent-swift).

PiKit wires a provider, a model and an agent together so applications do not
have to repeat the same boilerplate. It re-exports both packages, adds
`temperature` / `maxTokens` injection that `PiAgentCore.AgentOptions` cannot
express on its own, and ships small text and tool helpers.

> PiKit is **not** a port of an upstream TypeScript package. It depends on the
> Swift ports `PiAI` and `PiAgentCore`. See [`docs/PORTING.md`](docs/PORTING.md)
> and [`ATTRIBUTION.md`](ATTRIBUTION.md).

## Features

- ✅ `import PiKit` re-exports `PiAI` and `PiAgentCore`
- ✅ `AgentConfiguration` with documented defaults
- ✅ `AgentKit.model(_:)` / `AgentKit.agent(_:)` / `AgentKit.makeAgent(_:provider:)`
- ✅ `ConfiguredProvider`: injects `temperature` / `maxTokens` into every request
- ✅ `AgentText`: `text(of:)`, `finalAnswer(in:)`, `describe(_:)`
- ✅ `FunctionTool`: build an `AgentTool` from a JSON schema + closure
- ✅ Swift 6 strict concurrency, `Sendable` public types, zero warnings
- ✅ Tested with a fake `ChatProvider` (no network)

## Requirements

| | |
| --- | --- |
| Swift | 6.0+ (`swift-tools-version:6.0`) |
| Platforms | macOS 13+, iOS 16+ |
| Dependencies | `PiAI` 0.1.0, `PiAgentCore` 0.1.0 |

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/quyansiyuanwang/pi-kit-swift.git", from: "0.1.0")
],
targets: [
    .target(name: "MyApp", dependencies: ["PiKit"])
]
```

## Quick start

From configuration to `agent.prompt` in a few lines:

```swift
import PiKit

let configuration = AgentConfiguration(
    baseURL: "https://api.deepseek.com/v1",
    apiKey: ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"] ?? "",
    model: "deepseek-chat",
    systemPrompt: "You are a helpful assistant."
)
let agent = AgentKit.agent(configuration)
try await agent.prompt("Explain PiKit in one sentence.")
print(AgentText.finalAnswer(in: await agent.transcript))
```

Everything from `PiAI` and `PiAgentCore` is available without a second import.

### Adding a tool

`FunctionTool` turns a JSON schema and a closure into an `AgentTool`:

```swift
let weather = FunctionTool(
    name: "get_weather",
    description: "Get the current weather for a city.",
    parametersJSONSchema: .object([
        "type": "object",
        "properties": .object([
            "city": .object(["type": "string", "description": "City name."])
        ]),
        "required": .array([.string("city")])
    ]
) { call, onUpdate in
    let city = call.arguments["city"].stringValue ?? "unknown"
    onUpdate?(ToolResult(text: "Looking up \(city)…"))
    return ToolResult(text: "It is sunny in \(city).")
}

let agent = AgentKit.agent(AgentConfiguration(
    baseURL: "https://api.deepseek.com/v1",
    apiKey: key,
    model: "deepseek-chat",
    tools: [weather]
))
```

### Streaming events

`AgentKit.agent(_:)` returns a `PiAgentCore.Agent`, so the usual
`subscribe` / `abort` / `reset` API is available:

```swift
let unsubscribe = agent.subscribe { event in
    if case .messageUpdate(_, .textDelta(let delta)) = event { print(delta, terminator: "") }
}
try await agent.prompt("Tell me a story.")
unsubscribe()
```

### Injecting parameters with any provider

When you bring your own `ChatProvider` (including in tests), use
`makeAgent(_:provider:)`. It wraps the provider in `ConfiguredProvider` so the
configuration's `temperature` and `maxTokens` reach every `ChatOptions`:

```swift
let agent = AgentKit.makeAgent(configuration, provider: myProvider)
```

## API

```swift
public struct AgentConfiguration: Sendable {
    public var baseURL: String
    public var apiKey: String
    public var model: String
    public var provider: String        // default "deepseek"
    public var contextWindow: Int      // default 128_000
    public var maxTokens: Int?
    public var temperature: Double?
    public var systemPrompt: String
    public var tools: [any AgentTool]
    public init(baseURL:apiKey:model:provider:contextWindow:maxTokens:temperature:systemPrompt:tools:)
}

public enum AgentKit {
    public static func model(_ configuration: AgentConfiguration) -> Model
    public static func agent(_ configuration: AgentConfiguration) -> Agent
    public static func makeAgent(_ configuration: AgentConfiguration, provider: any ChatProvider) -> Agent
}

public struct ConfiguredProvider: ChatProvider {
    public init(_ base: any ChatProvider, temperature: Double? = nil, maxTokens: Int? = nil)
}

public enum AgentText {
    public static func text(of blocks: [ContentBlock]) -> String
    public static func finalAnswer(in messages: [Message]) -> String
    public static func describe(_ value: JSONValue) -> String
}

public struct FunctionTool: AgentTool {
    public init(
        name: String,
        description: String,
        parametersJSONSchema: JSONValue,
        execute: @escaping @Sendable (ToolCall, (@Sendable (ToolResult) -> Void)?) async throws -> ToolResult
    )
}
```

## Development

```sh
swift build -Xswiftc -warnings-as-errors
swift test  -Xswiftc -warnings-as-errors
```

CI runs both commands on a macOS runner
([`.github/workflows/ci.yml`](.github/workflows/ci.yml)).

## License

MIT. See [`LICENSE`](LICENSE) and [`ATTRIBUTION.md`](ATTRIBUTION.md).
