# PORTING — composition layer on PiAI + PiAgentCore

PiKit is **not** a port of an upstream TypeScript package. This document exists
to make that explicit: it records what PiKit does, why it exists, and the design
decisions behind the glue it adds on top of the Swift ports
[`PiAI`](https://github.com/quyansiyuanwang/pi-ai-swift) and
[`PiAgentCore`](https://github.com/quyansiyuanwang/pi-agent-swift).

## Why this package exists

`PiAI` provides providers and types; `PiAgentCore` provides the agent loop.
Using them together from an app means repeating the same wiring:

1. Build a `PiAI.Model` from URL / key / model id.
2. Build a `ChatProvider`.
3. Work around `PiAgentCore.AgentOptions` only forwarding `apiKey` (it has no
   `temperature` / `maxTokens`).
4. Write a `struct` per tool, even for one-liners.

PiKit packages that wiring once. Applications depend on `PiKit` only.

## Status

| Requirement | Implementation | Status |
| --- | --- | --- |
| Unified re-export | `PiKit.swift` (`@_exported`) | ✅ |
| Configuration + assembly | `AgentConfiguration.swift`, `AgentKit.swift` | ✅ |
| Parameter injection | `ConfiguredProvider.swift` | ✅ |
| Text helpers | `AgentText.swift` | ✅ |
| Closure-backed tool | `FunctionTool.swift` | ✅ |
| Tests (fake provider) | `Tests/PiKitTests/**` | ✅ |
| Docs / LICENSE / CI | `README.md`, `LICENSE`, `ATTRIBUTION.md`, `.github/workflows/ci.yml` | ✅ |

## File mapping

| File | Responsibility |
| --- | --- |
| `Sources/PiKit/PiKit.swift` | `@_exported import PiAI` + `@_exported import PiAgentCore`; namespace version. |
| `Sources/PiKit/AgentConfiguration.swift` | `AgentConfiguration` value type with defaulted convenience initializer. |
| `Sources/PiKit/AgentKit.swift` | `model(_:)`, `agent(_:)`, `makeAgent(_:provider:)`. |
| `Sources/PiKit/ConfiguredProvider.swift` | `ChatProvider` decorator that injects `temperature` / `maxTokens`. |
| `Sources/PiKit/AgentText.swift` | `text(of:)`, `finalAnswer(in:)`, `describe(_:)`. |
| `Sources/PiKit/FunctionTool.swift` | `AgentTool` built from a JSON schema + closure. |

## Design decisions

These are intentional choices of the composition layer, not deviations from an
upstream source.

1. **`ConfiguredProvider` is override-based.** `PiAgentCore.AgentOptions` only
   carries `apiKey`, so `Agent` builds `ChatOptions(apiKey:signal:)` with no
   sampling parameters. `ConfiguredProvider` wraps the real provider and, for
   each request, replaces `temperature` / `maxTokens` when the configuration
   supplies a non-`nil` value. A `nil` configuration value leaves the caller's
   options untouched. This keeps the decorator composable and predictable.

2. **`AgentKit.makeAgent(_:provider:)` is the injectable seam.** The public
   `agent(_:)` uses the default `OpenAICompletionsProvider`;
   `makeAgent(_:provider:)` accepts any `ChatProvider` so apps and tests can
   substitute their own. Both wrap the provider in `ConfiguredProvider`.

3. **`AgentConfiguration.maxTokens` has a fallback in the model.** `Model`
   requires a non-optional `maxTokens`, while the configuration makes it
   optional. `AgentKit.model(_:)` falls back to a conservative default (4 096)
   only to populate `Model.maxTokens`; the request-level cap stays optional and
   is injected by `ConfiguredProvider` only when explicitly configured.

4. **`FunctionTool` bridges the `@Sendable` closure.** `AgentTool.execute`
   takes a non-`@Sendable` `onUpdate`, while the initializer required by the
   spec takes an `@Sendable` one. The conformance boxes the callback in a
   private `@unchecked Sendable` holder so no warning is emitted. The callback
   is only invoked synchronously from the tool body; `Agent` always supplies a
   sendable callback at runtime.

5. **`AgentText.describe(_:)` returns compact, key-sorted JSON.** An empty
   object and `null` render as `""`, which makes the helper convenient for
   optional tool details. Any other value is encoded with `.sortedKeys` so
   output is deterministic.

6. **`AgentKit` is a caseless enum namespace.** It only holds `static`
   functions, so it is never instantiated.

## Out of scope

- Multiple providers / automatic provider selection.
- Session persistence, credential stores, or remote model catalogs.
- A CLI or any executable target.
- Re-exporting anything beyond `PiAI` and `PiAgentCore`.
