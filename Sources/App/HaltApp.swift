import SwiftUI

struct HaltApp: App {
    @NSApplicationDelegateAdaptor private var delegate: AppDelegate
    private var engine: Engine { .shared }

    var body: some Scene {
        MenuBarExtra {
            PopoverView()
        } label: {
            MenuBarLabel()
        }
        .menuBarExtraStyle(.window)

        Window("Halt", id: "main") { MainView() }
            .defaultSize(width: 1160, height: 800)
            .defaultLaunchBehavior(engine.settings.onboarded && !engine.showSetup ? .suppressed : .presented)
    }
}
