import SwiftUI

struct Card<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }
            .padding(14).frame(maxWidth: .infinity, alignment: .leading)
            // Nearly solid: text on see-through glass washes out over a bright window.
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.88), in: .rect(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.primary.opacity(0.1)))
    }
}
