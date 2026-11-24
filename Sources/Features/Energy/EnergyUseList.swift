import SwiftUI

struct EnergyUseList: View {
    @State private var apps: [AppEnergyUse]?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Using significant energy").font(.headline)
            if let apps {
                if apps.isEmpty { Text("Nothing right now").foregroundStyle(.secondary) }
                ForEach(apps) { app in
                    let running = NSRunningApplication(processIdentifier: pid_t(app.id))
                    HStack(spacing: 8) {
                        if let icon = running?.icon {
                            Image(nsImage: icon).resizable().frame(width: 20, height: 20)
                        } else {
                            Image(systemName: "gearshape.2.fill").foregroundStyle(.secondary).frame(width: 20)
                        }
                        Text(running?.localizedName ?? app.name).lineLimit(1)
                        Spacer()
                        Gauge(value: min(100, app.power), in: 0...100) {}.gaugeStyle(.accessoryLinearCapacity)
                            .tint(.orange).frame(width: 70)
                    }
                    .accessibilityElement(children: .combine)
                }
            } else {
                ProgressView().controlSize(.small)
            }
        }
        .task {
            while !Task.isCancelled {
                apps = await Task.detached { Self.read() }.value
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    private nonisolated static func read() -> [AppEnergyUse] {
        let process = Process(), pipe = Pipe()
        process.executableURL = URL(filePath: "/usr/bin/top")
        process.arguments = ["-l", "2", "-n", "5", "-o", "power", "-stats", "pid,power,command"]
        process.standardOutput = pipe
        guard (try? process.run()) != nil else { return [] }
        return parseTop(String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self))
    }
}
