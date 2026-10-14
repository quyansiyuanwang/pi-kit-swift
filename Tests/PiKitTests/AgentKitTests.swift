import PiAI
import PiAgentCore
import Testing

@testable import PiKit

@Suite("AgentKit")
struct AgentKitTests {
    @Test("model maps the configuration onto PiAI.Model")
    func modelMapsConfiguration() {
        let configuration = AgentConfiguration(
            baseURL: "https://api.example.test/v1",
            apiKey: "secret",
            model: "deepseek-chat",
            provider: "deepseek",
            contextWindow: 64_000,
            maxTokens: 2_048,
            temperature: 0.3,
            systemPrompt: "You are helpful."
        )

        let model = AgentKit.model(configuration)

        #expect(model.id == "deepseek-chat")
        #expect(model.name == "deepseek-chat")
        #expect(model.api == "openai-completions")
        #expect(model.provider == "deepseek")
        #expect(model.baseURL == "https://api.example.test/v1")
        #expect(model.contextWindow == 64_000)
        #expect(model.maxTokens == 2_048)
    }

    @Test("model falls back to a default output cap when maxTokens is nil")
    func modelFallsBackForMaxTokens() {
        let configuration = AgentConfiguration(
            baseURL: "https://api.example.test/v1",
            model: "m"
        )

        let model = AgentKit.model(configuration)

        #expect(model.maxTokens > 0)
        #expect(model.provider == "deepseek")
        #expect(model.contextWindow == 128_000)
    }

    @Test("makeAgent wires options, tools and injected parameters")
    func makeAgentAssemblesOptions() async throws {
        let provider = MockProvider(responses: [Fixtures.assistant(text: "hello back")])
        let tool = FunctionTool(
            name: "echo",
            description: "Echo a value",
            parametersJSONSchema: .object([
                "type": "object",
                "properties": .object(["value": .object(["type": "string"])])
            ])
        ) { call, _ in
            ToolResult(text: call.arguments["value"].stringValue ?? "")
        }

        let configuration = AgentConfiguration(
            baseURL: "https://api.example.test/v1",
            apiKey: "secret-key",
            model: "test-model",
            provider: "test",
            contextWindow: 32_000,
            maxTokens: 512,
            temperature: 0.2,
            systemPrompt: "Be concise.",
            tools: [tool]
        )

        let agent = AgentKit.makeAgent(configuration, provider: provider)
        try await agent.prompt("hi")

        #expect(provider.options.count == 1)
        let options = try #require(provider.options.first)
        #expect(options.apiKey == "secret-key")
        #expect(options.temperature == 0.2)
        #expect(options.maxTokens == 512)

        let context = try #require(provider.contexts.first)
        #expect(context.systemPrompt == "Be concise.")
        #expect(context.tools.count == 1)
        #expect(context.tools.first?.name == "echo")
        #expect(context.tools.first?.parameters.isObject == true)

        let transcript = await agent.transcript
        #expect(AgentText.finalAnswer(in: transcript) == "hello back")
    }

    @Test("agent uses the default OpenAI-compatible provider")
    func agentUsesDefaultProvider() {
        let configuration = AgentConfiguration(
            baseURL: "https://api.example.test/v1",
            model: "test-model"
        )

        // Construction must not require network access.
        _ = AgentKit.agent(configuration)
    }
}
