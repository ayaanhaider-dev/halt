import SwiftUI

struct ControlStatus: View {
    private var engine: Engine { .shared }
    var body: some View {
        if engine.conflict {
            Label(
                "AlDente is running. Quit it so Halt can control charging.",
                systemImage: "exclamationmark.triangle")
        } else if engine.helperStatus != .enabled {
            HStack {
                Label(
                    engine.helperStatus == .outdated
                        ? "The helper needs an update." : "Charge control needs the helper.",
                    systemImage: "wrench.and.screwdriver")
                Button(engine.helperStatus == .outdated ? "Update…" : "Install…") { engine.installHelper() }
            }
        } else if let error = engine.error {
            Label(error, systemImage: "exclamationmark.triangle")
        }
    }
}
