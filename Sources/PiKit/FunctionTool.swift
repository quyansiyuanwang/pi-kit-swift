import PiAI
import PiAgentCore

/// Builds a ``PiAgentCore/AgentTool`` from a JSON schema and a closure.
///
/// Writing a dedicated `struct` per tool is boilerplate; `FunctionTool`
/// collapses it to a schema plus an execution closure:
///
/// ```swift
/// let weather = FunctionTool(
///     name: "get_weather",
///     description: "Get the current weather for a city.",
///     parametersJSONSchema: .object([
///         "type": "object",
///         "properties": .object([
///             "city": .object(["type": "string"])
///         ]),
///         "required": .array([.string("city")])
///     ]
/// ) { call, onUpdate in
///     let city = call.arguments["city"].stringValue ?? "unknown"
///     onUpdate?(ToolResult(text: "Looking up \(city)…"))
///     return ToolResult(text: "It is sunny in \(city).")
/// }
/// ```
public struct FunctionTool: AgentTool {
    public let name: String
    public let description: String
    public let parametersJSONSchema: JSONValue

    private let body: @Sendable (ToolCall, (@Sendable (ToolResult) -> Void)?) async throws -> ToolResult

    /// Creates a function-backed tool.
    ///
    /// - Parameters:
    ///   - name: Unique tool name used in the model's `tool_calls`.
    ///   - description: Human-readable description shown to the model.
    ///   - parametersJSONSchema: JSON Schema for the tool arguments.
    ///   - execute: The tool body. It receives the ``PiAI/ToolCall`` and an
    ///     optional callback for streaming partial results.
    public init(
        name: String,
        description: String,
        parametersJSONSchema: JSONValue,
        execute: @escaping @Sendable (ToolCall, (@Sendable (ToolResult) -> Void)?) async throws -> ToolResult
    ) {
        self.name = name
        self.description = description
        self.parametersJSONSchema = parametersJSONSchema
        self.body = execute
    }

    public func execute(
        _ call: ToolCall,
        onUpdate: ((ToolResult) -> Void)?
    ) async throws -> ToolResult {
        guard let onUpdate else {
            return try await body(call, nil)
        }
        // The protocol erases `@Sendable` from `onUpdate`; `Agent` always
        // supplies a sendable callback. Boxing preserves that guarantee while
        // satisfying the protocol's non-Sendable signature.
        let box = ClosureBox(onUpdate)
        return try await body(call) { result in box.call(result) }
    }
}

/// Carries a callback across the `@Sendable` boundary of ``FunctionTool``'s body.
///
/// Safe in practice because the callback is only invoked synchronously from the
/// tool body, on the task that called ``FunctionTool/execute(_:onUpdate:)``.
private final class ClosureBox: @unchecked Sendable {
    private let closure: (ToolResult) -> Void

    init(_ closure: @escaping (ToolResult) -> Void) {
        self.closure = closure
    }

    func call(_ result: ToolResult) {
        closure(result)
    }
}
