import Foundation

struct BatterySample: Identifiable {
    let id: Date
    let percent, temperature, watts, health, cycles: Double
}

/// One CSV line a minute, kept 30 days.
enum BatteryHistory {
    private static let url = URL.applicationSupportDirectory.appending(path: "Halt/history.csv")

    static func load() -> [BatterySample] {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        let cutoff = Date.now.addingTimeInterval(-30 * 86400)
        let lines = text.split(separator: "\n")
        let samples = lines.compactMap { line -> BatterySample? in
            let f = line.split(separator: ",").compactMap { Double($0) }
            guard f.count >= 5, f[0] > cutoff.timeIntervalSince1970 else { return nil }
            return BatterySample(
                id: Date(timeIntervalSince1970: f[0]), percent: f[1], temperature: f[2], watts: f[3],
                health: f[4], cycles: f.count > 5 ? f[5] : 0)
        }
        if samples.count < lines.count {
            try? samples.map(line).joined().write(to: url, atomically: true, encoding: .utf8)
        }
        return samples
    }

    private static func line(_ s: BatterySample) -> String {
        "\(s.id.timeIntervalSince1970),\(s.percent),\(s.temperature),\(s.watts),\(s.health),\(Int(s.cycles))\n"
    }

    static func append(_ sample: BatterySample) {
        let data = Data(line(sample).utf8)
        if let file = try? FileHandle(forWritingTo: url) {
            defer { try? file.close() }
            _ = try? file.seekToEnd()
            try? file.write(contentsOf: data)
        } else {
            try? FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? data.write(to: url)
        }
    }
}
