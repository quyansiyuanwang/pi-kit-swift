import PiAI
import PiAgentCore

/// Everything needed to stand up a provider, a model and an agent.
///
/// The convenience initializer applies the documented defaults so callers only
/// have to supply what actually varies:
///
/// ```swift
/// let configuration = AgentConfiguration(
///     baseURL: "https://api.deepseek.com/v1",
///     apiKey: ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"] ?? "",
///     model: "deepseek-chat"
/// )
/// ```
public struct AgentConfiguration: Sendable {
    /// Base URL of the OpenAI-compatible endpoint.
    public var baseURL: String
    /// API key forwarded to the provider.
    public var apiKey: String
    /// Model id used in requests.
    public var model: String
    /// Provider discriminator used by ``PiAI/Model``. Defaults to `deepseek`.
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
    /// Tools exposed to the model.
    public var tools: [any AgentTool]

    /// Creates a configuration with the documented defaults.
    ///
    /// - Parameters:
    ///   - baseURL: Base URL of the OpenAI-compatible endpoint.
    ///   - apiKey: API key forwarded to the provider. Defaults to `""`.
    ///   - model: Model id used in requests.
    ///   - provider: Provider discriminator. Defaults to `"deepseek"`.
    ///   - contextWindow: Advertised context window. Defaults to `128_000`.
    ///   - maxTokens: Output-token cap. Defaults to `nil` (no cap).
    ///   - temperature: Sampling temperature. Defaults to `nil` (provider default).
    ///   - topP: Nucleus sampling. Defaults to `nil`.
    ///   - frequencyPenalty: Frequency penalty. Defaults to `nil`.
    ///   - presencePenalty: Presence penalty. Defaults to `nil`.
    ///   - systemPrompt: System prompt. Defaults to `""`.
    ///   - tools: Tools exposed to the model. Defaults to `[]`.
    public init(
        baseURL: String,
        apiKey: String = "",
        model: String,
        provider: String = "deepseek",
        contextWindow: Int = 128_000,
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        frequencyPenalty: Double? = nil,
        presencePenalty: Double? = nil,
        systemPrompt: String = "",
        tools: [any AgentTool] = []
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.model = model
        self.provider = provider
        self.contextWindow = contextWindow
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.topP = topP
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
        self.systemPrompt = systemPrompt
        self.tools = tools
    }
}
