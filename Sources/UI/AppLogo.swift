import SwiftUI

struct AppLogo: View {
    var size: CGFloat = 34
    var body: some View {
        Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
