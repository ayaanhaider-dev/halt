import SwiftUI

/// A wide glass capsule that takes on a color while on.
struct CapsuleButtonStyle: ButtonStyle {
    let on: Bool, color: Color
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.medium)
            .foregroundStyle(
                on ? AnyShapeStyle(.black.opacity(0.8)) : AnyShapeStyle(.primary.opacity(enabled ? 1 : 0.5))
            )
            .frame(maxWidth: .infinity).frame(height: 34)
            .contentShape([.interaction, .focusEffect], .capsule)
            // Tinted glass turns gray in an inactive window, hiding which button is on.
            .background(on ? color : .clear, in: .capsule)
            .glassEffect(on ? .identity : .regular.interactive(enabled), in: .capsule)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
