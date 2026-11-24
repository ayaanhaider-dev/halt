import Charts
import SwiftUI

struct HistoryChart: View {
    let metric: HistoryMetric
    let samples: [BatterySample]
    @State private var hovered: Date?

    var body: some View {
        let points = metric.points(from: samples)
        let selected = nearest(in: points)
        VStack(alignment: .leading, spacing: 8) {
            Text(metric.caption).font(.caption).foregroundStyle(.secondary)
                .opacity(selected == nil ? 1 : 0)
            chart(points, selected: selected)
                .chartOverlay(content: hoverArea)
                .chartYScale(domain: metric.range(of: points))
                .chartXAxis { AxisMarks(values: .automatic(desiredCount: 4)) { AxisValueLabel() } }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 3)) {
                        AxisGridLine().foregroundStyle(.quaternary)
                        AxisValueLabel()
                    }
                }
                .frame(height: 200).padding(.top, 6)
        }
    }

    private func nearest(in points: [BatterySample]) -> BatterySample? {
        guard let hovered else { return nil }
        return points.min {
            abs($0.id.timeIntervalSince(hovered)) < abs($1.id.timeIntervalSince(hovered))
        }
    }

    private func chart(_ points: [BatterySample], selected: BatterySample?) -> some View {
        let low = metric.range(of: points).lowerBound
        return Chart {
            ForEach(points) {
                AreaMark(
                    x: .value("Time", $0.id), yStart: .value("Base", low),
                    yEnd: .value(metric.rawValue, $0[keyPath: metric.value])
                )
                .foregroundStyle(metric.color.opacity(0.14))
                LineMark(x: .value("Time", $0.id), y: .value(metric.rawValue, $0[keyPath: metric.value]))
                    .foregroundStyle(metric.color).lineStyle(StrokeStyle(lineWidth: 2))
            }
            if let selected {
                RuleMark(x: .value("Time", selected.id)).foregroundStyle(Color.gray.opacity(0.6))
                    .annotation(
                        position: .top, spacing: 4,
                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
                    ) { readout(selected) }
                PointMark(
                    x: .value("Time", selected.id),
                    y: .value(metric.rawValue, selected[keyPath: metric.value])
                )
                .foregroundStyle(metric.color).symbolSize(70)
            }
        }
    }

    // Solid on purpose: glass picks up the line's colors.
    private func readout(_ sample: BatterySample) -> some View {
        HStack(spacing: 6) {
            Text(metric.label(for: sample)).fontWeight(.semibold)
            Text(sample.id.formatted(date: metric.coversMonth ? .abbreviated : .omitted, time: .shortened))
                .foregroundStyle(.secondary)
        }
        .font(.callout.monospacedDigit()).fixedSize()
        .padding(.horizontal, 10).padding(.vertical, 4)
        .background(Color(nsColor: .windowBackgroundColor), in: .capsule)
        .overlay(Capsule().strokeBorder(.gray.opacity(0.4)))
    }

    private func hoverArea(_ proxy: ChartProxy) -> some View {
        GeometryReader { geometry in
            Color.clear.contentShape(.rect).onContinuousHover { phase in
                guard case .active(let point) = phase, let plot = proxy.plotFrame else {
                    hovered = nil
                    return
                }
                hovered = proxy.value(atX: point.x - geometry[plot].minX)
            }
        }
    }
}
