import PiAI
import PiAgentCore
import Testing

@testable import PiKit

@Suite("FunctionTool")
struct FunctionToolTests {
    static let schema: JSONValue = .object([
        "type": "object",
        "properties": .object([
            "city": .object([
                "type": "string",
                "description": "City name."
            ])
        ]),
        "required": .array([.string("city")])
    ])

    @Test("exposes the schema through parametersJSONSchema")
    func exposesSchema() {
        let tool = FunctionTool(
            name: "get_weather",
            description: "Get the weather",
            parametersJSONSchema: Self.schema
        ) { _, _ in ToolResult(text: "ok") }

        #expect(tool.name == "get_weather")
        #expect(tool.description == "Get the weather")
        #expect(tool.parametersJSONSchema == Self.schema)
        #expect(tool.parametersJSONSchema["required"].arrayValue?.first?.stringValue == "city")
    }

    @Test("executes the closure and forwards updates")
    func executesClosure() async throws {
        let spy = ToolSpy()
        let tool = FunctionTool(
            name: "get_weather",
            description: "Get the weather",
            parametersJSONSchema: Self.schema
        ) { call, onUpdate in
            spy.record(call: call)
            onUpdate?(ToolResult(text: "looking up"))
            let city = call.arguments["city"].stringValue ?? "unknown"
            return ToolResult(text: "sunny in \(city)", details: .object(["city": .string(city)]))
        }

        let call = ToolCall(id: "call-1", name: "get_weather", arguments: .object(["city": .string("Paris")]))
        let result = try await tool.execute(call) { spy.record(update: $0) }

        #expect(AgentText.text(of: result.content) == "sunny in Paris")
        #expect(result.details?["city"].stringValue == "Paris")
        #expect(result.isError == false)
        #expect(spy.recordedCalls.count == 1)
        #expect(spy.recordedUpdates == ["looking up"])
    }

    @Test("executes without an update callback")
    func executesWithoutUpdateCallback() async throws {
        let tool = FunctionTool(
            name: "echo",
            description: "Echo",
            parametersJSONSchema: .object(["type": "object"])
        ) { call, onUpdate in
            onUpdate?(ToolResult(text: "ignored"))
            return ToolResult(text: call.arguments["value"].stringValue ?? "")
        }

        let call = ToolCall(id: "call-2", name: "echo", arguments: .object(["value": .string("hi")]))
        let result = try await tool.execute(call, onUpdate: nil)

        #expect(AgentText.text(of: result.content) == "hi")
    }

    @Test("schema passes through to the provider context")
    func schemaPassesThroughToProvider() async throws {
        let provider = MockProvider(responses: [Fixtures.assistant(text: "done")])
        let tool = FunctionTool(
            name: "get_weather",
            description: "Get the weather",
            parametersJSONSchema: Self.schema
        ) { _, _ in ToolResult(text: "ok") }

        let agent = AgentKit.makeAgent(
            AgentConfiguration(
                baseURL: "https://api.example.test/v1",
                model: "test-model",
                tools: [tool]
            ),
            provider: provider
        )
        try await agent.prompt("weather?")

        let recorded = try #require(provider.contexts.first?.tools.first)
        let wireSchema = recorded.parameters.makeJSONValue()
        #expect(wireSchema["type"].stringValue == "object")
        #expect(wireSchema["required"].arrayValue?.first?.stringValue == "city")
        #expect(wireSchema["properties"]["city"]["type"].stringValue == "string")
    }
}
