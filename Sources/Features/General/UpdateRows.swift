import SwiftUI

struct UpdateRows: View {
    @ObservedObject private var updates = UpdateChecker.shared

    var body: some View {
        SettingRow(icon: "arrow.down.circle.fill", title: "Updates", note: "Halt \(Bundle.main.version)") {
            Button("Check Now") { updates.check() }.buttonStyle(.glass).disabled(!updates.canCheck)
        }
        SettingRow(
            icon: "calendar", title: "Check daily", note: "Asks GitHub for the latest version",
            on: updates.checksAutomatically
        ) {
            Toggle("Check daily", isOn: $updates.checksAutomatically)
        }
        SettingRow(
            icon: "bolt.horizontal.fill", title: "Install automatically", note: "The next time Halt quits",
            on: updates.installsAutomatically
        ) {
            Toggle("Install automatically", isOn: $updates.installsAutomatically)
                .disabled(!updates.checksAutomatically)
        }
    }
}

extension Bundle {
    var version: String { object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "–" }
}
