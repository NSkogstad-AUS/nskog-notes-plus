import SwiftUI

@main
struct NskogNotesPlusApp: App {
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environmentObject(appViewModel)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .sidebar) { }
        }
    }
}
