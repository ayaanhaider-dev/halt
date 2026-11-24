import SwiftUI

struct EnergyView: View {
    @State private var engine = Engine.shared
    var body: some View {
        SettingsPage(title: "Energy", note: "What your Mac is using, and how to use less.") {
            TitledCard("Modes") {
                SettingRow(
                    icon: "battery.25percent", title: "Low Power Mode",
                    note: "Slows your Mac slightly to save energy", on: engine.lowPower
                ) {
                    Toggle(
                        "Low Power Mode",
                        isOn: Binding(get: { engine.lowPower }, set: { engine.setLowPower($0) })
                    ).disabled(engine.helperStatus != .enabled)
                }
                Divider()
                SettingRow(
                    icon: "cup.and.saucer.fill", title: "Always awake when plugged in",
                    note: "Stops your Mac sleeping when idle", on: engine.settings.keepAwake
                ) {
                    Toggle("Always awake when plugged in", isOn: $engine.settings.keepAwake)
                }
            }
            TitledCard("Keep awake") {
                let settings = engine.settings, on = settings.awake(.now)
                HStack {
                    Text(
                        !on
                            ? "Your Mac sleeps as usual."
                            : settings.awakeUntil == .distantFuture
                                ? "Awake until you stop it."
                                : "Awake until \(settings.awakeUntil!.formatted(date: .omitted, time: .shortened))."
                    )
                    .font(.headline)
                    Spacer()
                    if on { Button("Stop") { engine.stopAwake() }.buttonStyle(.glass) }
                }
                HStack(spacing: 10) {
                    ForEach(AwakeDuration.all, id: \.name) { choice in
                        Button {
                            engine.keepAwake(hours: choice.hours)
                        } label: {
                            Text(choice.name).fontWeight(.medium).lineLimit(1).minimumScaleFactor(0.8)
                        }
                        .buttonStyle(
                            ChoiceButtonStyle(
                                on: on && choice.hours == nil && settings.awakeUntil == .distantFuture))
                    }
                }
                Divider()
                SettingRow(
                    icon: "battery.25percent", title: "Stop on low battery",
                    note: "So your Mac never drains to empty"
                ) {
                    HStack {
                        Text("\(settings.awakeCutoff ?? 20)%").monospacedDigit()
                        Stepper(
                            "Stop on low battery",
                            value: Binding(
                                get: { settings.awakeCutoff ?? 20 }, set: { engine.settings.awakeCutoff = $0 }
                            ), in: 5...80, step: 5
                        ).labelsHidden()
                    }
                }
                SettingRow(
                    icon: "laptopcomputer", title: "Even with the lid closed",
                    note: "Don't put it in a bag like this: it gets hot", on: settings.awakeLid == true
                ) {
                    Toggle(
                        "Even with the lid closed",
                        isOn: Binding(
                            get: { settings.awakeLid == true }, set: { engine.settings.awakeLid = $0 })
                    ).disabled(engine.helperStatus != .enabled)
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                PowerCard()
                Card { EnergyUseList().padding(6) }
            }
        }
    }
}
