import SwiftUI

/// A named card.
struct TitledCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.title3.bold())
            Card { VStack(alignment: .leading, spacing: 14) { content }.padding(6) }
        }
    }
}
