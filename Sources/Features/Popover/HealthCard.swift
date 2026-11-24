import SwiftUI

struct HealthCard: View {
    var body: some View {
        let battery = Engine.shared.battery
        Group {
            Card {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 14) {
                        Gauge(value: min(100, battery.health), in: 0...100) {
                        } currentValueLabel: {
                            Text("\(Int(battery.health.rounded()))%").fontWeight(.semibold)
                        }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .tint(battery.health >= 80 ? Color.halt : .orange)
                        .accessibilityLabel("Battery health")
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Battery health").font(.headline)
                            Text("Condition: \(battery.condition)").foregroundStyle(faint)
                            Text(verbatim: "Holds \(battery.maximum) of \(battery.design) mAh")
                                .foregroundStyle(faint)
                                .help(
                                    "macOS reports \(battery.design > 0 ? battery.nominal * 100 / battery.design : 0)% (\(String(battery.nominal)) mAh)"
                                )
                        }
                        .monospacedDigit()
                    }
                    HStack(spacing: 0) {
                        stat(degrees(battery.temperature), "Temperature").foregroundStyle(
                            battery.temperature >= 35 ? .orange : .primary)
                        stat("\(battery.cycles)", "Charge cycles")
                        stat("\(battery.charge) mAh", "Charge left")
                    }
                }
                .padding(4)
            }
        }
        .lineLimit(1).minimumScaleFactor(0.8)
        // A tight popover would squeeze the text to different sizes.
        .fixedSize(horizontal: false, vertical: true)
    }

    private var faint: Color { .primary.opacity(0.6) }

    private func stat(_ value: String, _ name: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).fontWeight(.semibold).monospacedDigit()
            Text(name).font(.caption).foregroundStyle(faint)
        }
        .frame(maxWidth: .infinity, alignment: .leading).accessibilityElement(children: .combine)
    }
}
