import SwiftUI

extension AppearanceView {
    /// The real popover, smaller and not clickable.
    var preview: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 14) {
                HStack(spacing: 5) {
                    if let icon = engine.barImage {
                        MenuBarSymbol(name: icon).foregroundStyle(
                            engine.settings.barTint == true && engine.lowPower ? .yellow : .primary)
                    }
                    Text(engine.barText).monospacedDigit()
                }
                .padding(.horizontal, 9).frame(height: 22).background(.quaternary, in: .capsule)
                Image(systemName: "wifi").foregroundStyle(.secondary)
                Image(systemName: "switch.2").foregroundStyle(.secondary)
            }
            .lineLimit(1).frame(maxWidth: 384 * scale, alignment: .trailing)
            PopoverView()
                .fixedSize(horizontal: false, vertical: true)
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { height = $0 }
                .clipShape(.rect(cornerRadius: 24)).overlay(
                    RoundedRectangle(cornerRadius: 24).strokeBorder(.primary.opacity(0.15))
                )
                .scaleEffect(scale, anchor: .topTrailing)
                .frame(width: 384 * scale, height: height * scale, alignment: .topTrailing)
        }
        .padding(14).background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 20))
        .disabled(true).allowsHitTesting(false).accessibilityHidden(true)
        .animation(.smooth(duration: 0.3), value: engine.settings.showDetails)
        .animation(.smooth(duration: 0.3), value: engine.settings.showFlow)
    }
}
