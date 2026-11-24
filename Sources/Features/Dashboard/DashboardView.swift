import SwiftUI

/// Three levels: the battery now, its key facts, then history and details.
struct DashboardView: View {
    @State private var engine = Engine.shared
    @State private var metric = HistoryMetric.level

    var body: some View {
        let battery = engine.battery
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                ControlStatus()
                Card {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 28) {
                            control.frame(minWidth: 340)
                            PowerFlowView(flow: battery.flow).frame(width: 290)
                        }
                        VStack(spacing: 22) {
                            control
                            PowerFlowView(flow: battery.flow)
                        }
                    }
                    .padding(10)
                }
                HStack(alignment: .top, spacing: 12) {
                    fact(
                        "\(Int(battery.health.rounded()))%", "Health",
                        "\(battery.maximum) of \(battery.design) mAh")
                    fact(
                        degrees(battery.temperature), "Temperature",
                        battery.temperature >= 35 ? "Warm" : "Normal")
                    fact("\(battery.cycles)", "Cycles", "Condition: \(battery.condition)")
                    fact(watts(battery.flow.system), "Power use", "Right now")
                }
                .padding(.horizontal, 10)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("History").font(.title2.bold())
                        Spacer()
                        Picker("Show", selection: $metric) {
                            ForEach(HistoryMetric.allCases, id: \.self) { Text($0.rawValue) }
                        }
                        .pickerStyle(.segmented).labelsHidden().fixedSize()
                    }
                    Card { HistoryChart(metric: metric, samples: engine.samples) }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details").font(.title2.bold())
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top, spacing: 14) {
                            PowerCard().frame(minWidth: 330)
                            Card { EnergyUseList() }.frame(minWidth: 250)
                        }
                        VStack(spacing: 14) {
                            PowerCard()
                            Card { EnergyUseList() }
                        }
                    }
                    .font(.callout)
                }
            }
            .padding(24).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }
    }

    private var control: some View {
        VStack(alignment: .leading, spacing: 16) {
            ChargeHeader(size: 60)
            ChargeLimitSlider()
            ChargeButtons()
        }
    }

    private func fact(_ value: String, _ name: String, _ note: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name).foregroundStyle(.secondary)
            Text(value).font(.system(.title, design: .rounded).weight(.semibold).monospacedDigit())
            Text(verbatim: note).font(.caption).foregroundStyle(.secondary)
        }
        .lineLimit(1).minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, alignment: .leading).accessibilityElement(children: .combine)
    }
}
