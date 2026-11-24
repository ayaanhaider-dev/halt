import SwiftUI

struct UpdateRow: View {
    @State private var engine = Engine.shared
    @State private var updates = UpdateChecker.shared

    var body: some View {
        SettingRow(icon: "arrow.down.circle.fill", title: "Updates", note: note, on: isAvailable) {
            if case .available(_, let page) = updates.state {
                Button("Get It…") { NSWorkspace.shared.open(page) }.buttonStyle(.glassProminent)
            } else {
                Button("Check Now") { Task { await updates.check() } }.buttonStyle(.glass)
                    .disabled(updates.state == .checking)
            }
        }
        SettingRow(
            icon: "calendar", title: "Check daily", note: "Asks GitHub for the latest version",
            on: checksDaily.wrappedValue
        ) {
            Toggle("Check daily", isOn: checksDaily)
        }
    }

    private var checksDaily: Binding<Bool> {
        Binding(
            get: { engine.settings.skipUpdateCheck != true },
            set: { engine.settings.skipUpdateCheck = !$0 })
    }

    private var isAvailable: Bool {
        if case .available = updates.state { return true }
        return false
    }

    private var note: String {
        switch updates.state {
        case .idle: "Halt \(Bundle.main.version)"
        case .checking: "Checking…"
        case .current: "Halt \(Bundle.main.version) is the latest"
        case .available(let version, _): "Halt \(version) is ready"
        case .failed(let message): message
        }
    }
}
