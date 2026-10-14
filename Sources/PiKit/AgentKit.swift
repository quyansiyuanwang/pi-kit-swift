import PiAI
import PiAgentCore

/// Assembles a provider, a model and an agent from an ``AgentConfiguration``.
///
/// This is the one-stop entry point for applications: it removes the
/// boilerplate of building a ``PiAI/Model``, wrapping the provider so
/// `temperature` / `maxTokens` reach ``PiAI/ChatOptions``, and populating
/// ``PiAgentCore/AgentOptions``.
public enum AgentKit {
    /// Fallback output-token cap used when ``AgentConfiguration/maxTokens`` is `nil`
    /// (``PiAI/Model`` requires a non-optional `maxTokens`).
    private static let defaultMaxTokens = 4_096

    /// Builds a ``PiAI/Model`` from the configuration.
    ///
    /// The model's `api` is always `"openai-completions"`.
    public static func model(_ configuration: AgentConfiguration) -> Model {
        Model(
            id: configuration.model,
            name: configuration.model,
            api: "openai-completions",
            provider: configuration.provider,
            baseURL: configuration.baseURL,
            contextWindow: configuration.contextWindow,
            maxTokens: configuration.maxTokens ?? defaultMaxTokens
        )
    }

    /// Builds an agent backed by the default ``PiAI/OpenAICompletionsProvider``.
    public static func agent(_ configuration: AgentConfiguration) -> Agent {
        makeAgent(configuration, provider: OpenAICompletionsProvider())
    }

    /// Builds an agent with an explicit ``PiAI/ChatProvider``.
    ///
    /// The provider is wrapped in a ``ConfiguredProvider`` so
    /// ``AgentConfiguration/temperature`` and
    /// ``AgentConfiguration/maxTokens`` are injected into every request, since
    /// ``PiAgentCore/AgentOptions`` only forwards `apiKey`.
    ///
    /// - Parameters:
    ///   - configuration: Provider/model/tool configuration.
    ///   - provider: The streaming provider to wrap.
    /// - Returns: A configured, ready-to-prompt agent.
    public static func makeAgent(
        _ configuration: AgentConfiguration,
        provider: any ChatProvider
    ) -> Agent {
        let configured = ConfiguredProvider(
            provider,
            temperature: configuration.temperature,
            maxTokens: configuration.maxTokens
        )
        let options = AgentOptions(
            systemPrompt: configuration.systemPrompt,
            model: model(configuration),
            tools: configuration.tools,
            provider: configured,
            apiKey: configuration.apiKey
        )
        return Agent(options: options)
    }
}
