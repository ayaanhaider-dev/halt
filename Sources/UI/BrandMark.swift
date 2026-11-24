import AppKit

enum BrandMark {
    /// Stands in for a symbol name where the menu bar shows Halt's own mark.
    static let menuBar = "haltTemplate"
    static let template: NSImage? = {
        let image = NSImage(named: menuBar)
        image?.isTemplate = true
        return image
    }()
}
