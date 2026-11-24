import SwiftUI

/// The maker's wordmark, which links to their site.
struct LvenoLink: View {
    @Environment(\.colorScheme) private var scheme
    var height: CGFloat = 22

    var body: some View {
        Link(destination: URL(string: "https://lveno.agency/")!) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("by").foregroundStyle(.secondary)
                if let url = Bundle.main.url(
                    forResource: "lveno-wordmark-\(scheme == .dark ? "dark" : "light")", withExtension: "svg"),
                    let image = NSImage(contentsOf: url)
                {
                    Image(nsImage: image).resizable().scaledToFit().frame(height: height)
                        // The file has space around the word, and its letters stand at 100 of 132.
                        .alignmentGuide(.firstTextBaseline) { $0.height * 100 / 132 }
                        .padding(.leading, -height * 0.2)
                } else {
                    Text("Lveno")
                }
            }
        }
        // macOS puts its focus outline on the first control of a window, which was this.
        .buttonStyle(.plain).focusable(false).help("lveno.agency").accessibilityLabel(
            "by Lveno, opens lveno.agency")
    }
}
