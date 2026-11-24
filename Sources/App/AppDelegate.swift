import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        Engine.shared.applyDock()
        _ = UpdateChecker.shared
        // MenuBarExtra has no right click of its own; its button lives in a status bar window.
        NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) { event in
            guard event.window?.className.contains("StatusBar") == true else { return event }
            return Engine.shared.rightClicked() ? nil : event
        }
    }

    /// Clicking the Dock icon.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        MainActor.assumeIsolated { Engine.shared.openWindow() }
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        MainActor.assumeIsolated { Engine.shared.prepareToQuit() }
    }
}
