import SwiftUI

struct GeneralView: View {
    @State private var engine = Engine.shared
    @State private var confirm = false
    var body: some View {
        let ready = engine.helperStatus == .enabled
        SettingsPage(title: "General", note: "Startup, the helper, and your Mac.") {
            TitledCard("Startup") {
                SettingRow(
                    icon: "power", title: "Launch at login", note: "Needed for schedules and heat protection",
                    on: engine.launchAtLogin
                ) { Toggle("Launch at login", isOn: $engine.launchAtLogin) }
                Divider()
                SettingRow(
                    icon: "dock.rectangle", title: "Show in Dock",
                    note: "Also lets you switch to Halt with Command-Tab", on: engine.settings.dock != false
                ) {
                    Toggle(
                        "Show in Dock",
                        isOn: Binding(
                            get: { engine.settings.dock != false },
                            set: {
                                engine.settings.dock = $0
                                engine.applyDock()
                            }))
                }
                Divider()
                SettingRow(icon: "sparkles", title: "Setup", note: "Answer the setup questions again") {
                    Button("Start…") { engine.showSetup = true }.buttonStyle(.glass)
                }
            }
            TitledCard("Helper") {
                SettingRow(
                    icon: ready ? "checkmark" : "exclamationmark",
                    title: ready
                        ? "Ready" : engine.helperStatus == .outdated ? "Needs an update" : "Not installed",
                    note: "Changes the charge limit, MagSafe light and Low Power Mode", on: ready
                ) {
                    if ready {
                        Button("Remove…") { confirm = true }.buttonStyle(.glass)
                    } else {
                        Button(engine.helperStatus == .outdated ? "Update…" : "Install…") {
                            engine.installHelper()
                        }.buttonStyle(.glassProminent)
                    }
                }
                if ready || engine.error != nil { ControlStatus() }
            }
            TitledCard("Updates") { UpdateRow() }
            TitledCard("About") {
                HStack(spacing: 14) {
                    AppLogo(size: 64)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Halt").font(.title2.bold())
                        LvenoLink(height: 24)
                    }
                }
                LabeledContent(
                    "Version",
                    value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                        ?? "–")
                LabeledContent("Battery serial number") {
                    Text(engine.battery.serial).textSelection(.enabled)
                }
                LabeledContent("Adapter", value: engine.battery.adapterName)
                if !engine.battery.adapterFirmware.isEmpty {
                    LabeledContent("Adapter firmware", value: engine.battery.adapterFirmware)
                }
                SettingRow(
                    icon: "doc.text.magnifyingglass", title: "Debug report",
                    note: "Settings and battery state, without serial numbers"
                ) { Button("Save…", action: engine.saveReport).buttonStyle(.glass) }
            }
            .labeledContentStyle(SpreadLabeledContentStyle())
        }
        .confirmationDialog("Remove the helper?", isPresented: $confirm) {
            Button("Remove", role: .destructive) { engine.removeHelper() }
        } message: {
            Text("Charging and the MagSafe light return to normal first.")
        }
    }
}
