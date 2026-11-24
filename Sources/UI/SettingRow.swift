import SwiftUI

/// A setting: symbol, name, what it does, and its control on the right.
struct SettingRow<Control: View>: View {
    let icon: String, title: String, note: String
    var on = false
    @ViewBuilder let control: Control

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(
                on ? AnyShapeStyle(.black.opacity(0.8)) : AnyShapeStyle(.secondary)
            )
            .frame(width: 34, height: 34).background(
                on ? AnyShapeStyle(Color.halt) : AnyShapeStyle(.quaternary), in: .circle)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).fontWeight(.medium)
                Text(note).font(.callout).foregroundStyle(.secondary)
            }
            Spacer(minLength: 12)
            control.labelsHidden()
        }
    }
}
