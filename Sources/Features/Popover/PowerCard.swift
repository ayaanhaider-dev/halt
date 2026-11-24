import SwiftUI

struct PowerCard: View {
    private let faint = Color.primary.opacity(0.6)

    var body: some View {
        let battery = Engine.shared.battery
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Power right now").font(.headline)
                    Spacer()
                    if let minutes = battery.minutes, !battery.plugged || Engine.shared.mode == .charging {
                        Text("\(time(minutes)) \(battery.plugged ? "to 100%" : "left")").foregroundStyle(
                            faint
                        ).monospacedDigit()
                    }
                }
                if battery.plugged {
                    row(
                        "powerplug.fill", "From adapter", watts(battery.flow.adapter),
                        "\(amount(battery.adapterVolts, "V")), \(amount(battery.adapterAmps, "A"))"
                    ).help("Rated \(battery.adapterWatts) W")
                }
                if abs(battery.flow.battery) < 1 {
                    row("battery.75percent", "Battery", "Resting", amount(battery.voltage, "V"))
                } else {
                    row(
                        "battery.75percent", battery.flow.battery > 0 ? "Into battery" : "From battery",
                        watts(abs(battery.flow.battery)),
                        "\(amount(battery.voltage, "V")), \(amount(abs(battery.liveCurrent), "A"))")
                }
                row("laptopcomputer", "Used by Mac", watts(battery.flow.system), "")
            }
            .padding(4)
        }
        .lineLimit(1).minimumScaleFactor(0.8).fixedSize(horizontal: false, vertical: true)
    }

    private func row(_ icon: String, _ name: String, _ value: String, _ note: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(faint).frame(width: 22)
            Text(name)
            Spacer()
            Text(note).font(.caption).foregroundStyle(faint)
            Text(value).fontWeight(.semibold).frame(minWidth: 58, alignment: .trailing)
        }
        .monospacedDigit().accessibilityElement(children: .combine)
    }
}
