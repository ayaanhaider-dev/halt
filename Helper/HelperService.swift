import Foundation

/// Runs as root. Offers only the commands in `HelperProtocol`.
final class HelperService: NSObject, HelperProtocol, NSXPCListenerDelegate {
    private let queue = DispatchQueue(label: helperID)

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        connection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.exportedObject = self
        // Restarted on demand, so an updated Halt gets its updated helper.
        connection.invalidationHandler = { [weak self] in self?.stop() }
        connection.resume()
        return true
    }

    func setLimit(_ percent: Int, pauseOptimized: Bool, reply: @escaping (String?) -> Void) {
        queue.async { reply(ChargeLimit.set(percent, pauseOptimized: pauseOptimized)) }
    }

    func setLED(_ state: Int, reply: @escaping (String?) -> Void) {
        queue.async {
            // 0 macOS decides, 1 off, 3 green, 4 orange, 6 blinking orange.
            guard [0, 1, 3, 4, 6].contains(state) else { return reply("Unknown light setting.") }
            reply(
                SMC()?.writeByte("ACLC", UInt8(state)) == true
                    ? nil : "This Mac didn't accept the MagSafe light setting.")
        }
    }

    private var sleepDisabled = false

    func setLowPower(_ on: Bool, reply: @escaping (String?) -> Void) {
        queue.async { reply(self.pmset("lowpowermode", on)) }
    }

    func setSleepDisabled(_ on: Bool, reply: @escaping (String?) -> Void) {
        queue.async {
            let message = self.pmset("disablesleep", on)
            if message == nil { self.sleepDisabled = on }
            reply(message)
        }
    }

    func uninstall(reply: @escaping (String?) -> Void) {
        queue.async {
            if self.sleepDisabled { _ = self.pmset("disablesleep", false) }
            do {
                for path in [
                    "/Library/LaunchDaemons/\(helperID).plist", "/Library/PrivilegedHelperTools/\(helperID)",
                ] { try FileManager.default.removeItem(atPath: path) }
                reply(nil)
                // Ends this process, so it comes after the reply has had time to leave.
                self.queue.asyncAfter(deadline: .now() + 0.5) {
                    _ = try? Process.run(
                        URL(filePath: "/bin/launchctl"), arguments: ["bootout", "system/\(helperID)"])
                }
            } catch { reply(error.localizedDescription) }
        }
    }

    private func pmset(_ key: String, _ on: Bool) -> String? {
        do {
            let process = try Process.run(
                URL(filePath: "/usr/bin/pmset"), arguments: ["-a", key, on ? "1" : "0"])
            process.waitUntilExit()
            return process.terminationStatus == 0 ? nil : "Couldn't change \(key)."
        } catch { return error.localizedDescription }
    }

    /// Halt is gone: a Mac that can't sleep must never outlive it.
    func stop() {
        queue.async {
            if self.sleepDisabled { _ = self.pmset("disablesleep", false) }
            exit(0)
        }
    }
}
