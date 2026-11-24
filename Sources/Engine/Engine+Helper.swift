import Foundation

extension Engine {
    nonisolated func report(_ message: String?) {
        guard let message else { return }
        Task { @MainActor in self.error = message }
    }

    func helper(_ body: (HelperProtocol) -> Void) {
        if connection == nil {
            let c = NSXPCConnection(machServiceName: helperID, options: .privileged)
            c.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
            c.invalidationHandler = { Task { @MainActor in Engine.shared.connection = nil } }
            c.resume()
            connection = c
        }
        if let proxy = connection?.remoteObjectProxyWithErrorHandler({ self.report($0.localizedDescription) })
            as? HelperProtocol
        {
            body(proxy)
        }
    }

    func setLowPower(_ on: Bool) { helper { $0.setLowPower(on, reply: report) } }

    func installHelper() {
        // Waits for the password, so not on the main thread.
        Task {
            let message = await Task.detached { HelperStatus.install() }.value
            // A connection to the replaced helper is no use any more.
            connection?.invalidate()
            connection = nil
            applied = nil
            helperStatus = .read()
            error = message
            apply()
        }
    }

    func removeHelper() {
        settings.led = .system
        settings.dischargeTarget = nil
        // The Mac must be able to sleep again before the helper is gone.
        settings.awakeLid = nil
        settings.dischargeLid = nil
        updateAwake()
        release(limit: 100)
        helper {
            $0.uninstall { message in
                self.report(message)
                Task { @MainActor in
                    self.applied = nil
                    self.helperStatus = .read()
                }
            }
        }
    }

    /// Before quitting: temporary overrides would otherwise stay in force.
    func prepareToQuit() {
        if settings.effectiveLimit != settings.limit || settings.led == .status {
            release(limit: settings.limit)
        }
    }

    func release(limit: Int) {
        guard helperStatus == .enabled, !conflict else { return }
        let done = DispatchSemaphore(value: 0)
        helper { h in h.setLimit(limit, pauseOptimized: false) { _ in h.setLED(0) { _ in done.signal() } } }
        _ = done.wait(timeout: .now() + 3)
    }
}
