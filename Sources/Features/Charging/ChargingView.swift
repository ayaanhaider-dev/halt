import SwiftUI

struct ChargingView: View {
    @State private var engine = Engine.shared

    var body: some View {
        let settings = engine.settings
        SettingsPage(title: "Charging", note: "How full the battery gets, and when charging pauses.") {
            ControlStatus()
            TitledCard("Charge limit") {
                ChargeLimitSlider()
                ChargeButtons()
                Text(
                    "Above the limit, macOS drains the battery while plugged in. Changes can take a few minutes, and macOS sometimes charges to 100% to calibrate itself."
                )
                .font(.callout).foregroundStyle(.secondary)
            }
            TitledCard("Heat protection") {
                SettingRow(
                    icon: "thermometer.high", title: "Pause charging when hot",
                    note: "The battery is \(degrees(engine.battery.temperature)) now",
                    on: settings.heatProtection
                ) {
                    Toggle("Pause charging when hot", isOn: $engine.settings.heatProtection)
                }
                if settings.heatProtection {
                    HStack(spacing: 12) {
                        Slider(value: $engine.settings.heatLimit, in: 30...45, step: 1) {
                            Text("Pause above")
                        }.labelsHidden()
                        Text(degrees(settings.heatLimit)).fontWeight(.semibold).monospacedDigit().frame(
                            width: 64, alignment: .trailing)
                    }
                }
            }
            TitledCard("MagSafe light") {
                HStack(spacing: 10) {
                    ForEach(MagSafeLight.allCases, id: \.self) { led in
                        let on = settings.led == led
                        Button {
                            engine.settings.led = led
                        } label: {
                            VStack(spacing: 8) {
                                Circle().fill(swatch(led)).frame(width: 16, height: 16).overlay(
                                    Circle().strokeBorder(.primary.opacity(0.25)))
                                Text(led.rawValue).font(.callout).lineLimit(1).minimumScaleFactor(0.8)
                            }
                        }
                        .buttonStyle(ChoiceButtonStyle(on: on)).accessibilityAddTraits(on ? .isSelected : [])
                    }
                }
                if settings.led == .status {
                    Divider()
                    SettingRow(
                        icon: "checkmark.circle.fill", title: "Green at the limit",
                        note: "Otherwise it stays orange while plugged in", on: settings.ledNoLimit != true
                    ) {
                        Toggle(
                            "Green at the limit",
                            isOn: Binding(
                                get: { settings.ledNoLimit != true },
                                set: { engine.settings.ledNoLimit = !$0 }))
                    }
                    SettingRow(
                        icon: "light.beacon.max.fill", title: "Blink while draining",
                        note: "Slow orange blink", on: settings.ledNoBlink != true
                    ) {
                        Toggle(
                            "Blink while draining",
                            isOn: Binding(
                                get: { settings.ledNoBlink != true },
                                set: { engine.settings.ledNoBlink = !$0 }))
                    }
                }
            }
            TitledCard("Discharging") {
                SettingRow(
                    icon: "laptopcomputer", title: "Keep going with the lid closed",
                    note: "While discharging or calibrating, and only plugged in",
                    on: settings.dischargeLid == true
                ) {
                    Toggle(
                        "Keep going with the lid closed",
                        isOn: Binding(
                            get: { settings.dischargeLid == true }, set: { engine.settings.dischargeLid = $0 }
                        )
                    ).disabled(engine.helperStatus != .enabled)
                }
            }
            TitledCard("Calibration") {
                CalibrationControls()
                Divider()
                SettingRow(
                    icon: "apple.logo", title: "After macOS calibrates",
                    note: "macOS sometimes charges to 100% by itself"
                ) {
                    Picker(
                        "After macOS calibrates",
                        selection: Binding(
                            get: { settings.calibrateAfterMac == true },
                            set: { engine.settings.calibrateAfterMac = $0 })
                    ) {
                        Text("Return to limit").tag(false)
                        Text("Calibrate fully").tag(true)
                    }.fixedSize()
                }
                SettingRow(
                    icon: "battery.100percent", title: "Last full charge", note: "Seen while Halt was open"
                ) {
                    Text(
                        (settings.lastFull ?? engine.samples.last { $0.percent >= 100 }?.id)?.formatted(
                            date: .abbreviated, time: .shortened) ?? "Not yet"
                    ).foregroundStyle(.secondary)
                }
            }
        }
    }

    private func swatch(_ led: MagSafeLight) -> AnyShapeStyle {
        switch led {
        case .system: AnyShapeStyle(.gray)
        case .status: AnyShapeStyle(Color.halt)
        case .off: AnyShapeStyle(.clear)
        case .green: AnyShapeStyle(.green)
        case .orange: AnyShapeStyle(.orange)
        }
    }
}
