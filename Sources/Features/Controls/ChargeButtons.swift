import SwiftUI

struct ChargeButtons: View {
    @State private var engine = Engine.shared

    var body: some View {
        let battery = engine.battery, settings = engine.settings
        GlassEffectContainer {
            HStack(spacing: 10) {
                Button("Discharge", systemImage: "arrow.down") {
                    if settings.dischargeTarget == nil { engine.discharge() } else { engine.run(nil) }
                }
                .buttonStyle(
                    CapsuleButtonStyle(on: settings.dischargeTarget != nil, color: ChargeMode.draining.color)
                )
                .disabled(
                    settings.dischargeTarget == nil
                        && (!battery.plugged || engine.helperStatus != .enabled
                            || (battery.percent <= 20 && battery.percent <= settings.limit))
                )
                .accessibilityAddTraits(settings.dischargeTarget != nil ? .isSelected : [])
                if settings.calibration != nil {
                    Button("Stop", systemImage: "stop.fill") { engine.run(nil) }.buttonStyle(
                        CapsuleButtonStyle(on: true, color: ChargeMode.holding.color))
                } else {
                    Button("Top Up", systemImage: "arrow.up") { engine.run(settings.topUp ? nil : .topUp) }
                        .buttonStyle(CapsuleButtonStyle(on: settings.topUp, color: ChargeMode.charging.color))
                        .accessibilityAddTraits(settings.topUp ? .isSelected : [])
                }
            }
        }
    }
}
