import Foundation
import PiAI
import PiAgentCore
import Testing

@testable import PiKit

// MARK: - Fixtures

enum Fixtures {
    static let model = Model(
        id: "test-model",
        name: "Test Model",
        api: "openai-completions",
        provider: "test",
        baseURL: "https://example.test/v1",
        contextWindow: 128_000,
        maxTokens: 4_096
    )

    static func assistant(text: String) -> AssistantMessage {
        AssistantMessage(
            content: [.text(TextContent(text: text))],
            api: model.api,
            provider: model.provider,
            model: model.id,
            stopReason: .stop,
            timestamp: 0
        )
    }
}

// MARK: - Programmable provider

/// A ``ChatProvider`` that replays scripted assistant messages and records the
/// requests it received so tests can assert on assembly and option injection.
final class MockProvider: ChatProvider, @unchecked Sendable {
    private let lock = NSLock()
    private let responses: [AssistantMessage]
    private var cursor = 0
    private var recordedContexts: [ChatContext] = []
    private var recordedOptions: [ChatOptions] = []

    init(responses: [AssistantMessage] = []) {
        self.responses = responses
    }

    var contexts: [ChatContext] {
        lock.lock()
        defer { lock.unlock() }
        return recordedContexts
    }

    var options: [ChatOptions] {
        lock.lock()
        defer { lock.unlock() }
        return recordedOptions
    }

    func stream(
        model: Model,
        context: ChatContext,
        options: ChatOptions
    ) -> AsyncThrowingStream<AssistantMessageEvent, any Error> {
        lock.lock()
        recordedContexts.append(context)
        recordedOptions.append(options)
        let message: AssistantMessage
        if responses.isEmpty {
            message = AssistantMessage()
        } else {
            message = responses[min(cursor, responses.count - 1)]
            cursor += 1
        }
        lock.unlock()

        return AsyncThrowingStream { continuation in
            continuation.yield(.start)
            continuation.yield(.done(message))
            continuation.finish()
        }
    }
}

// MARK: - Spies

/// Thread-safe recorder for tool execution and update callbacks.
final class ToolSpy: @unchecked Sendable {
    private let lock = NSLock()
    private var updates: [String] = []
    private var calls: [ToolCall] = []

    func record(call: ToolCall) {
        lock.lock()
        calls.append(call)
        lock.unlock()
    }

    func record(update: ToolResult) {
        lock.lock()
        updates.append(AgentText.text(of: update.content))
        lock.unlock()
    }

    var recordedUpdates: [String] {
        lock.lock()
        defer { lock.unlock() }
        return updates
    }

    var recordedCalls: [ToolCall] {
        lock.lock()
        defer { lock.unlock() }
        return calls
    }
}

// MARK: - Async helpers

/// Drains a provider stream so recorded side effects are visible.
func drain(_ stream: AsyncThrowingStream<AssistantMessageEvent, any Error>) async throws {
    for try await _ in stream {}
}
