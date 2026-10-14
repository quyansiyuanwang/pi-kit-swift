import PiAI
import Testing

@testable import PiKit

@Suite("ConfiguredProvider")
struct ConfiguredProviderTests {
    @Test("injects temperature and maxTokens into every request")
    func injectsConfiguredOptions() async throws {
        let recorder = MockProvider()
        let provider = ConfiguredProvider(recorder, temperature: 0.7, maxTokens: 128)

        try await drain(provider.stream(
            model: Fixtures.model,
            context: ChatContext(),
            options: ChatOptions(apiKey: "key")
        ))

        let options = try #require(recorder.options.first)
        #expect(options.apiKey == "key")
        #expect(options.temperature == 0.7)
        #expect(options.maxTokens == 128)
    }

    @Test("configured values override caller-supplied options")
    func configuredValuesOverride() async throws {
        let recorder = MockProvider()
        let provider = ConfiguredProvider(recorder, temperature: 0.9, maxTokens: 64)

        try await drain(provider.stream(
            model: Fixtures.model,
            context: ChatContext(),
            options: ChatOptions(apiKey: "key", temperature: 0.1, maxTokens: 9)
        ))

        let options = try #require(recorder.options.first)
        #expect(options.temperature == 0.9)
        #expect(options.maxTokens == 64)
    }

    @Test("nil configuration leaves caller options untouched")
    func nilConfigurationIsPassThrough() async throws {
        let recorder = MockProvider()
        let provider = ConfiguredProvider(recorder)

        try await drain(provider.stream(
            model: Fixtures.model,
            context: ChatContext(),
            options: ChatOptions(apiKey: "key", temperature: 0.1, maxTokens: 9)
        ))

        let options = try #require(recorder.options.first)
        #expect(options.temperature == 0.1)
        #expect(options.maxTokens == 9)
    }

    @Test("forwards the model and context unchanged")
    func forwardsRequestContext() async throws {
        let recorder = MockProvider()
        let provider = ConfiguredProvider(recorder)
        let context = ChatContext(
            systemPrompt: "system",
            messages: [.user(UserMessage(content: "hello", timestamp: 0))],
            tools: [Tool(name: "t", description: "d", parameters: JSONSchema.object())]
        )

        try await drain(provider.stream(
            model: Fixtures.model,
            context: context,
            options: ChatOptions(apiKey: "key")
        ))

        let recorded = try #require(recorder.contexts.first)
        #expect(recorded.systemPrompt == "system")
        #expect(recorded.messages.count == 1)
        #expect(recorded.tools.first?.name == "t")
    }
}
