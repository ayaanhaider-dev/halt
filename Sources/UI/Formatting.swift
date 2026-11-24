import Foundation

func amount(_ value: Double, _ unit: String) -> String {
    "\(value.formatted(.number.precision(.fractionLength(2)))) \(unit)"
}
func time(_ minutes: Int?) -> String { minutes.map { "\($0 / 60)h \($0 % 60)m" } ?? "–" }

func watts(_ value: Double) -> String { "\(value.formatted(.number.precision(.fractionLength(1)))) W" }
func degrees(_ value: Double) -> String {
    Measurement(value: value, unit: UnitTemperature.celsius).formatted(
        .measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(1))))
}
