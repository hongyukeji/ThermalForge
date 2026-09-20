import Foundation

enum WakeRecovery {
    /// Called after the wake delay. Read the current hold while excluding SMC
    /// writes, so an intervening reset/new command cannot be overwritten by a
    /// pre-sleep snapshot. Preserve an active safety floor even with no hold.
    @discardableResult
    static func reapply(
        lock: NSLock, snapshot: () -> DaemonHoldState,
        apply: (String) throws -> Void
    ) rethrows -> String? {
        lock.lock()
        defer { lock.unlock() }
        let state = snapshot()
        let command = state.safetySuspended ? "max" : state.command
        guard let command else { return nil }
        try apply(command)
        return command
    }
}
