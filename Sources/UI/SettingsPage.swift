import SwiftUI

/// The same frame for every settings page: what it is for, then cards.
struct SettingsPage<Content: View>: View {
    let title: String, note: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.system(size: 34, weight: .bold, design: .rounded))
                    Text(note).foregroundStyle(.secondary)
                }
                content
            }
            .padding(28).frame(maxWidth: 820, alignment: .leading).frame(maxWidth: .infinity)
        }
    }
}
