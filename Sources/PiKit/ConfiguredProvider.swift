import PiAI
import PiAgentCore

/// A ``PiAI/ChatProvider`` that injects fixed sampling parameters into every
/// request.
///
/// ``PiAgentCore/AgentOptions`` only forwards `apiKey` to the provider, so an
/// agent cannot express `temperature` / `maxTokens` on its own. Wrapping the
/// provider closes that gap:
///
/// ```swift
/// let provider = ConfiguredProvider(
///     OpenAICompletionsProvider(),
///     temperature: 0.2,
///     maxTokens: 1_024
/// )
/// ```
///
/// Injection is override-based: a non-`nil` configured value replaces whatever
/// the caller passed, while a `nil` value leaves the incoming options
/// untouched.
public struct ConfiguredProvider: ChatProvider {
    /// The wrapped provider.
    public let base: any ChatProvider
    /// Temperature injected into every request, when non-`nil`.
    public let temperature: Double?
    /// Output-token cap injected into every request, when non-`nil`.
    public let maxTokens: Int?

    /// Wraps `base`.
    ///
    /// - Parameters:
    ///   - base: Provider whose request options are augmented.
    ///   - temperature: Value injected into ``PiAI/ChatOptions/temperature``.
    ///   - maxTokens: Value injected into ``PiAI/ChatOptions/maxTokens``.
    public init(
        _ base: any ChatProvider,
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) {
        self.base = base
        self.temperature = temperature
        self.maxTokens = maxTokens
    }

    /// Injects the configured parameters and forwards to ``base``.
    public func stream(
        model: Model,
        context: ChatContext,
        options: ChatOptions
    ) -> AsyncThrowingStream<AssistantMessageEvent, any Error> {
        var options = options
        if let temperature { options.temperature = temperature }
        if let maxTokens { options.maxTokens = maxTokens }
        return base.stream(model: model, context: context, options: options)
    }
}
