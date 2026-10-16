import PiAI
import PiAgentCore

/// Everything needed to stand up a provider, a model and an agent.
///
/// The convenience initializer applies the documented defaults so callers only
/// have to supply what actually varies:
///
/// ```swift
/// let configuration = AgentConfiguration(
///     baseURL: "https://api.openai.com/v1",
///     apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "",
///     model: "gpt-4o-mini"
/// )
/// ```
public struct AgentConfiguration: Sendable {
    /// Base URL of the OpenAI-compatible endpoint.
    public var baseURL: String
    /// API key forwarded to the provider.
    public var apiKey: String
    /// Model id used in requests.
    public var model: String
    /// API protocol discriminator used by ``PiAI/Model``.
    ///
    /// One of `openai-completions`, `openai-responses`, `anthropic-messages`,
    /// `google-generative-ai`. Defaults to `openai-completions`.
    public var api: String
    /// Provider label. Free-form; defaults to ``api``.
    public var provider: String
    /// Context window advertised by the model. Defaults to `128_000`.
    public var contextWindow: Int
    /// Output-token cap. When set it is also injected into every
    /// ``PiAI/ChatOptions`` by ``ConfiguredProvider``.
    public var maxTokens: Int?
    /// Sampling temperature injected into every ``PiAI/ChatOptions``.
    public var temperature: Double?
    /// Nucleus sampling parameter injected into every ``PiAI/ChatOptions``.
    public var topP: Double?
    /// Frequency penalty injected into every ``PiAI/ChatOptions``.
    public var frequencyPenalty: Double?
    /// Presence penalty injected into every ``PiAI/ChatOptions``.
    public var presencePenalty: Double?
    /// System prompt sent with every request.
    public var systemPrompt: String
    /// Maximum number of tool-execution rounds per prompt. Defaults to `8`.
    public var maxToolRounds: Int
    /// Tools exposed to the model.
    public var tools: [any AgentTool]

    /// Creates a configuration with the documented defaults.
    ///
    /// - Parameters:
    ///   - baseURL: Base URL of the OpenAI-compatible endpoint.
    ///   - apiKey: API key forwarded to the provider. Defaults to `""`.
    ///   - model: Model id used in requests.
    ///   - api: API protocol discriminator. Defaults to `"openai-completions"`.
    ///   - provider: Provider label. Defaults to `nil`, which uses `api`.
    ///   - contextWindow: Advertised context window. Defaults to `128_000`.
    ///   - maxTokens: Output-token cap. Defaults to `nil` (no cap).
    ///   - temperature: Sampling temperature. Defaults to `nil` (provider default).
    ///   - topP: Nucleus sampling. Defaults to `nil`.
    ///   - frequencyPenalty: Frequency penalty. Defaults to `nil`.
    ///   - presencePenalty: Presence penalty. Defaults to `nil`.
    ///   - systemPrompt: System prompt. Defaults to `""`.
    ///   - maxToolRounds: Maximum tool-execution rounds. Defaults to `8`.
    ///   - tools: Tools exposed to the model. Defaults to `[]`.
    public init(
        baseURL: String,
        apiKey: String = "",
        model: String,
        api: String = "openai-completions",
        provider: String? = nil,
        contextWindow: Int = 128_000,
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        frequencyPenalty: Double? = nil,
        presencePenalty: Double? = nil,
        systemPrompt: String = "",
        maxToolRounds: Int = 8,
        tools: [any AgentTool] = []
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.model = model
        self.api = api
        self.provider = provider ?? api
        self.contextWindow = contextWindow
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.topP = topP
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
        self.systemPrompt = systemPrompt
        self.maxToolRounds = maxToolRounds
        self.tools = tools
    }
}
