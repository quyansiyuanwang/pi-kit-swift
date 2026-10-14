import Foundation
import PiAI
import PiAgentCore

/// Small helpers for reading text out of ``PiAI`` messages and values.
public enum AgentText {
    /// Concatenates the text of every ``PiAI/ContentBlock/text`` block.
    ///
    /// Non-text blocks (thinking, images, tool calls) are ignored.
    public static func text(of blocks: [ContentBlock]) -> String {
        var result = ""
        for block in blocks {
            if case .text(let content) = block {
                result += content.text
            }
        }
        return result
    }

    /// The text of the last assistant message that has non-empty text.
    ///
    /// Tool-call-only assistant turns carry no text, so they are skipped.
    /// Returns `""` when no assistant message has text.
    public static func finalAnswer(in messages: [Message]) -> String {
        for message in messages.reversed() {
            if case .assistant(let assistant) = message {
                let text = text(of: assistant.content)
                if !text.isEmpty { return text }
            }
        }
        return ""
    }

    /// Renders a ``PiAI/JSONValue`` as compact, key-sorted JSON.
    ///
    /// An empty object (and `null`) renders as `""`, which makes it convenient
    /// for optional tool arguments or detail payloads:
    ///
    /// ```swift
    /// AgentText.describe(.object([:]))                     // ""
    /// AgentText.describe(.object(["city": "Paris"]))       // {"city":"Paris"}
    /// ```
    public static func describe(_ value: JSONValue) -> String {
        if value.isNull { return "" }
        if let object = value.objectValue, object.isEmpty { return "" }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(value),
              let text = String(data: data, encoding: .utf8) else {
            return ""
        }
        return text
    }
}
