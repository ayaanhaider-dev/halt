import SwiftUI

struct ChargeHeader: View {
    var size: CGFloat = 38
    private var engine: Engine { .shared }

    var body: some View {
        let battery = engine.battery
        VStack(alignment: .leading, spacing: 0) {
            Text("\(battery.percent)%").font(
                .system(size: size, weight: .bold, design: .rounded).monospacedDigit()
            ).lineLimit(1).fixedSize()
            HStack(spacing: 6) {
                Circle().fill(engine.mode.color).frame(width: 8, height: 8)
                Text(
                    engine.settings.summary(
                        percent: battery.percent, plugged: battery.plugged, flow: battery.flow,
                        minutes: battery.minutes)
                ).fontWeight(.medium).lineLimit(1)
            }
        }
    }
}
