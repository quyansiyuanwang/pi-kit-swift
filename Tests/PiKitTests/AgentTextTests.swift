import PiAI
import Testing

@testable import PiKit

@Suite("AgentText")
struct AgentTextTests {
    @Test("text(of:) concatenates text blocks and ignores the rest")
    func textJoinsTextBlocks() {
        let blocks: [ContentBlock] = [
            .text(TextContent(text: "Hello ")),
            .thinking(ThinkingContent(thinking: "hmm")),
            .text(TextContent(text: "world")),
            .toolCall(ToolCall(id: "1", name: "t", arguments: .object([:])))
        ]

        #expect(AgentText.text(of: blocks) == "Hello world")
    }

    @Test("text(of:) is empty for no blocks")
    func textOfEmptyBlocks() {
        #expect(AgentText.text(of: []) == "")
    }

    @Test("finalAnswer(in:) returns the last assistant message")
    func finalAnswerUsesLastAssistant() {
        let messages: [Message] = [
            .assistant(Fixtures.assistant(text: "first")),
            .user(UserMessage(content: "again", timestamp: 0)),
            .assistant(Fixtures.assistant(text: "second"))
        ]

        #expect(AgentText.finalAnswer(in: messages) == "second")
    }

    @Test("finalAnswer(in:) skips textless assistant turns")
    func finalAnswerSkipsEmptyAssistant() {
        let messages: [Message] = [
            .assistant(Fixtures.assistant(text: "answer")),
            .assistant(Fixtures.assistant(text: ""))
        ]

        #expect(AgentText.finalAnswer(in: messages) == "answer")
    }

    @Test("finalAnswer(in:) is empty without an assistant message")
    func finalAnswerWithoutAssistant() {
        #expect(AgentText.finalAnswer(in: []) == "")
        #expect(AgentText.finalAnswer(in: [.user(UserMessage(content: "hi", timestamp: 0))]) == "")
    }

    @Test("describe(_:) renders an empty object as an empty string")
    func describeEmptyObject() {
        #expect(AgentText.describe(.object([:])) == "")
        #expect(AgentText.describe(.null) == "")
    }

    @Test("describe(_:) renders non-empty values as key-sorted JSON")
    func describeNonEmptyValue() {
        let text = AgentText.describe(.object([
            "b": .int(2),
            "a": .string("x")
        ]))

        #expect(!text.isEmpty)
        #expect(text.contains("\"a\""))
        #expect(text.contains("\"b\""))
        #expect(text.contains("\"x\""))
    }
}
