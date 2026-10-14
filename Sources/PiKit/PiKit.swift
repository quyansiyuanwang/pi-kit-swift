@_exported import PiAI
@_exported import PiAgentCore

/// PiKit — the composition layer over ``PiAI`` and ``PiAgentCore``.
///
/// `import PiKit` is all an app needs: both underlying modules are re-exported,
/// and ``AgentKit`` / ``AgentConfiguration`` assemble a ready-to-run agent.
public enum PiKit {
    /// The PiKit version.
    public static let version = "0.1.0"
}
