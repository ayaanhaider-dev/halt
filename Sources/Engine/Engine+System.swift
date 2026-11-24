import AppKit
import ServiceManagement

extension Engine {
    func saveReport() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Halt report.txt"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        var b = battery
        b.serial = "hidden"
        let text =
            "macOS \(ProcessInfo.processInfo.operatingSystemVersionString)\nhelper \(helperStatus) conflict \(conflict) error \(error ?? "none")\n\n\(settings)\n\n\(b)\n"
        do { try text.write(to: url, atomically: true, encoding: .utf8) } catch {
            self.error = error.localizedDescription
        }
    }

    var launchAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            do { try newValue ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister() } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
