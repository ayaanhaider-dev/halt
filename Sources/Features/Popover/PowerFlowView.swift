import SwiftUI

/// The adapter feeding the battery and the Mac, or the battery helping to feed the Mac.
struct PowerFlowView: View {
    let flow: PowerFlow

    private struct Stream { let icon: String, name: String, watts: Double, color: Color }

    // Under 1 W is sensor noise (a paused adapter still reads about 0.6 W).
    private var charging: Bool { flow.battery > 1 }
    // Space between the ends of two bands; the joined end is shorter by the same amount, so a band keeps its thickness.
    private var gap: CGFloat { streams.count > 1 ? 30 : 0 }
    private var streams: [Stream] {
        let mac = Stream(icon: "laptopcomputer", name: "Mac", watts: flow.system, color: .blue)
        if charging {
            return [
                Stream(icon: "battery.100percent.bolt", name: "Battery", watts: flow.battery, color: .green),
                mac,
            ]
        }
        let sources = [
            Stream(icon: "powerplug.fill", name: "Adapter", watts: flow.adapter, color: .blue),
            Stream(icon: "battery.75percent", name: "Battery", watts: -flow.battery, color: .orange),
        ].filter { $0.watts > 1 }
        return sources.isEmpty ? [mac] : sources
    }

    var body: some View {
        HStack(spacing: 4) {
            if charging { single("bolt.fill", flow.adapter) } else { column }
            ribbons
            if charging { column } else { single("laptopcomputer", flow.system) }
        }
        .frame(height: 150)
        .accessibilityElement()
        .accessibilityLabel("Power flow")
        .accessibilityValue(
            "Adapter \(watts(flow.adapter)), Mac \(watts(flow.system)), battery \(watts(flow.battery))")
    }

    /// Round on the outside, nearly square where it meets a band.
    private func block(leading: Bool) -> UnevenRoundedRectangle {
        .rect(
            topLeadingRadius: leading ? 18 : 3, bottomLeadingRadius: leading ? 18 : 3,
            bottomTrailingRadius: leading ? 3 : 18, topTrailingRadius: leading ? 3 : 18)
    }

    private func single(_ icon: String, _ value: Double) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
            Text(watts(value)).font(.caption.monospacedDigit()).lineLimit(1).minimumScaleFactor(0.7)
        }
        .frame(width: 52).frame(maxHeight: .infinity)
        .background(.quaternary, in: block(leading: charging))
        .padding(.vertical, gap / 2)
    }

    // True to the watts, except that a stream never gets too thin for its label.
    private func spans(_ height: CGFloat, joined: Bool) -> [ClosedRange<CGFloat>] {
        let total = streams.reduce(0) { $0 + $1.watts }
        let shares = streams.map { max(0.14, $0.watts / max(total, 0.1)) }
        let usable = height - gap
        var y = joined ? gap / 2 : 0
        return shares.map {
            let h = usable * $0 / shares.reduce(0, +)
            defer { y += h + (joined ? 0 : gap) }
            return y...(y + h)
        }
    }

    private var column: some View {
        GeometryReader { geo in
            let spans = spans(geo.size.height, joined: false)
            ForEach(streams.indices, id: \.self) { i in
                Image(systemName: streams[i].icon)
                    .frame(width: geo.size.width, height: spans[i].upperBound - spans[i].lowerBound)
                    .background(.quaternary, in: block(leading: !charging))
                    .offset(y: spans[i].lowerBound)
                    .help(streams[i].name)
            }
        }
        .frame(width: 52)
    }

    private var ribbons: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let inner = spans(geo.size.height, joined: true), outer = spans(geo.size.height, joined: false)
            ForEach(streams.indices, id: \.self) { i in
                let a = charging ? inner[i] : outer[i], b = charging ? outer[i] : inner[i]
                let ribbon = Path { p in
                    p.move(to: CGPoint(x: 0, y: a.lowerBound))
                    p.addCurve(
                        to: CGPoint(x: w, y: b.lowerBound), control1: CGPoint(x: w / 2, y: a.lowerBound),
                        control2: CGPoint(x: w / 2, y: b.lowerBound))
                    p.addLine(to: CGPoint(x: w, y: b.upperBound))
                    p.addCurve(
                        to: CGPoint(x: 0, y: a.upperBound), control1: CGPoint(x: w / 2, y: b.upperBound),
                        control2: CGPoint(x: w / 2, y: a.upperBound))
                }
                ribbon.fill(.quaternary)
                PowerFlowWave(color: streams[i].color).clipShape(ribbon)
                Text(watts(streams[i].watts)).font(.callout.bold().monospacedDigit())
                    .position(x: w / 2, y: (a.lowerBound + a.upperBound + b.lowerBound + b.upperBound) / 4)
            }
        }
    }
}
