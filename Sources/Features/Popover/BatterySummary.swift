import SwiftUI

/// The three numbers worth a look; the rest opens on demand.
struct BatterySummary: View {
    @State private var open = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let battery = Engine.shared.battery
        VStack(spacing: 10) {
            ZStack(alignment: .top) {
                if open {
                    VStack(spacing: 10) { BatteryDetails() }.transition(.opacity)
                } else {
                    Card {
                        HStack(spacing: 0) {
                            stat("\(Int(battery.health.rounded()))%", "Health")
                            stat(degrees(battery.temperature), "Temperature")
                            stat("\(battery.cycles)", "Cycles")
                        }
                    }
                    .transition(.opacity)
                }
            }
            .clipped()
            Button {
                withAnimation(reduceMotion ? nil : .smooth(duration: 0.35)) { open.toggle() }
            } label: {
                Label {
                    Text(open ? "Less" : "Details").frame(width: 44, alignment: .leading).contentTransition(
                        .identity)
                } icon: {
                    Image(systemName: "chevron.down").rotationEffect(.degrees(open ? 180 : 0))
                }
                .font(.caption.weight(.medium)).frame(maxWidth: .infinity).contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }

    private func stat(_ value: String, _ name: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(.title2, design: .rounded).weight(.semibold).monospacedDigit())
            Text(name).font(.caption).foregroundStyle(.primary.opacity(0.65))
        }
        .lineLimit(1).fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity).accessibilityElement(children: .combine)
    }
}
