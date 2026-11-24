import SwiftUI

/// A tile that can be on or off.
struct ChoiceButtonStyle: ButtonStyle {
    let on: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity).padding(.vertical, 14).padding(.horizontal, 4)
            .background(
                on ? AnyShapeStyle(Color.halt.opacity(0.18)) : AnyShapeStyle(.quaternary.opacity(0.5)),
                in: .rect(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12).strokeBorder(on ? Color.halt : .clear, lineWidth: 1.5)
            )
            .contentShape(.rect).opacity(configuration.isPressed ? 0.7 : 1)
    }
}
