import SwiftUI

extension MainView {
    func label(_ page: Page) -> some View {
        Label(page.rawValue, systemImage: page.icon).padding(.vertical, 4).badge(Text(badge(page))).tag(page)
    }

    /// What each page is doing, without opening it.
    func badge(_ page: Page) -> String {
        switch page {
        case .charging:
            engine.settings.calibration != nil
                ? "Calibrating" : engine.settings.heatHold != nil ? "Hot" : "\(engine.settings.shownLimit)%"
        case .energy: engine.lowPower ? "Low Power" : engine.settings.keepAwake ? "Awake" : ""
        case .schedule:
            engine.settings.tasks.contains(where: \.enabled)
                ? "\(engine.settings.tasks.count(where: \.enabled))" : ""
        case .general:
            if engine.helperStatus != .enabled || engine.conflict {
                "!"
            } else if case .available = UpdateChecker.shared.state {
                "Update"
            } else {
                ""
            }
        case .dashboard, .appearance: ""
        }
    }

    var status: some View {
        let battery = engine.battery
        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(battery.percent)%").font(.system(.title, design: .rounded).bold())
                Spacer()
                Text(watts(battery.flow.system)).font(.callout).foregroundStyle(.secondary)
            }
            .monospacedDigit()
            Gauge(value: Double(battery.percent), in: 0...100) {}.gaugeStyle(.accessoryLinearCapacity).tint(
                engine.mode.color
            ).accessibilityHidden(true)
            Text(
                engine.settings.summary(
                    percent: battery.percent, plugged: battery.plugged, flow: battery.flow, minutes: nil)
            ).font(.caption).foregroundStyle(.secondary).lineLimit(1)
        }
        .padding(14).glassEffect(.regular, in: .rect(cornerRadius: 18)).padding(.horizontal, 10).padding(
            .bottom, 6
        )
        .accessibilityElement(children: .combine)
    }
}
