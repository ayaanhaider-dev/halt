import SwiftUI

enum HistoryMetric: String, CaseIterable {
    case level = "Battery"
    case power = "Power"
    case temperature = "Temperature"
    case health = "Health"
    case cycles = "Cycles"

    var value: KeyPath<BatterySample, Double> {
        switch self {
        case .level: \.percent
        case .power: \.watts
        case .temperature: \.temperature
        case .health: \.health
        case .cycles: \.cycles
        }
    }

    var color: Color {
        switch self {
        case .level: .halt
        case .power: .purple
        case .temperature: .cyan
        case .health: .orange
        case .cycles: .pink
        }
    }

    var caption: String {
        switch self {
        case .level: "%, last 24 hours"
        case .power: "Watts, last 24 hours"
        case .temperature: "°C, last 24 hours"
        case .health: "%, last 30 days"
        case .cycles: "Cycles, last 30 days"
        }
    }

    var coversMonth: Bool { self == .health || self == .cycles }

    /// Whether the axis starts near the data instead of at zero.
    var isZoomed: Bool { self == .temperature || coversMonth }

    func label(for sample: BatterySample) -> String {
        switch self {
        case .level: "\(Int(sample.percent))%"
        case .power: watts(sample.watts)
        case .temperature: degrees(sample.temperature)
        case .health: "\(sample.health.formatted(.number.precision(.fractionLength(1))))%"
        case .cycles: "\(Int(sample.cycles)) cycles"
        }
    }

    /// At most about 300 points: a month holds 43,000, and more than that looks the same.
    func points(from samples: [BatterySample]) -> [BatterySample] {
        let shown =
            switch self {
            // Zero means the sample predates cycle tracking.
            case .cycles: samples.filter { $0.cycles > 0 }
            case .health: samples
            default: samples.filter { $0.id > .now.addingTimeInterval(-86_400) }
            }
        return stride(from: 0, to: shown.count, by: max(1, shown.count / 300)).map { shown[$0] }
    }

    func range(of points: [BatterySample]) -> ClosedRange<Double> {
        let values = points.map { $0[keyPath: value] }
        let low = isZoomed ? (values.min() ?? 0) - 1 : 0
        let high = self == .level ? 100 : (values.max() ?? 1) + 1
        return low...high
    }
}
