import Foundation

/// Follows a drag in 1% steps, but sticks to every 5% when within 1.
func snappedLimit(from start: Int, moved: Double) -> Int {
    let raw = min(100, max(0, Double(start) + moved)), five = (raw / 5).rounded() * 5
    return Int((abs(raw - five) <= 1 ? five : raw).rounded())
}

/// How long a charge lasts unplugged, in minutes; nil without enough data to say.
func runtime(percent: Int, capacity: Int, volts: Double, watts: Double) -> Int? {
    guard capacity > 0, volts > 0, watts > 0.5 else { return nil }
    return Int(Double(capacity) / 1000 * volts * Double(percent) / 100 / watts * 60)
}
