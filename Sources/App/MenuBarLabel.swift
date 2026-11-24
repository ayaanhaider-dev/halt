import SwiftUI

struct MenuBarLabel: View {
    @State private var engine = Engine.shared
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        let content = engine.menuBar
        Group {
            if let icon = content.icon {
                if content.isTinted, let image = tinted(icon) {
                    Image(nsImage: image).renderingMode(.original)
                } else {
                    MenuBarSymbol(name: icon)
                }
            }
            Text(content.text)
        }
        .onAppear {
            engine.openWindow = {
                openWindow(id: "main")
                NSApp.activate()
            }
        }
    }

    /// The menu bar recolors templates, so a tinted icon must not be one.
    private func tinted(_ name: String) -> NSImage? {
        NSImage(systemSymbolName: name, accessibilityDescription: nil)?
            .withSymbolConfiguration(.init(paletteColors: [.systemYellow]))
    }
}
