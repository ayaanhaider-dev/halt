import SwiftUI

/// Keep awake, one click from the menu bar.
struct AwakeMenu: View {
    @State private var engine = Engine.shared

    var body: some View {
        let on = engine.settings.awake(.now)
        Menu {
            if on { Button("Let it sleep", systemImage: "moon") { engine.stopAwake() } }
            Section("Keep awake") { AwakeDuration.buttons(engine) }
        } label: {
            Image(systemName: on ? "cup.and.saucer.fill" : "cup.and.saucer").foregroundStyle(
                on ? AnyShapeStyle(Color.halt) : AnyShapeStyle(.primary))
        }
        .menuStyle(.button).menuIndicator(.hidden).buttonStyle(.glass).buttonBorderShape(.circle).fixedSize()
        .help(on ? "Your Mac is being kept awake" : "Keep your Mac awake").accessibilityLabel("Keep awake")
    }
}
