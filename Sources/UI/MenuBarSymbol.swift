import SwiftUI

/// A symbol, or Halt's own mark.
struct MenuBarSymbol: View {
    let name: String
    var body: some View {
        if name == BrandMark.menuBar, let image = BrandMark.template {
            Image(nsImage: image)
        } else {
            Image(systemName: name)
        }
    }
}
