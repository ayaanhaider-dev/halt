import Foundation

struct AppEnergyUse: Identifiable {
    let id: Int
    let name: String
    let power: Double
}

/// Uses the second sample of `top`; its first one has no power numbers.
func parseTop(_ output: String) -> [AppEnergyUse] {
    guard let table = output.components(separatedBy: "PID ").last else { return [] }
    return table.split(separator: "\n").dropFirst().compactMap {
        let f = $0.split(separator: " ", maxSplits: 2)
        guard f.count == 3, let pid = Int(f[0]), let power = Double(f[1]), power >= 20 else { return nil }
        return AppEnergyUse(id: pid, name: f[2].trimmingCharacters(in: .whitespaces), power: power)
    }
}
