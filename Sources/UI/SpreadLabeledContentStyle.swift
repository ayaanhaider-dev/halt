import SwiftUI

struct SpreadLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            configuration.content.labelsHidden().fixedSize().foregroundStyle(.secondary)
        }
    }
}
