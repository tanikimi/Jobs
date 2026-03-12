import SwiftUI

@main
struct JobsApp: App {
    @AppStorage("selectedIconName") private var selectedIconName: String = "AppIcon"

    init() {
        let iconName = UserDefaults.standard.string(forKey: "selectedIconName") ?? "AppIcon"
        if let image = NSImage(named: iconName) {
            NSApplication.shared.applicationIconImage = image
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新規企業を追加") {
                    NotificationCenter.default.post(name: .addCompany, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }

        Settings {
            SettingsView()
        }
    }
}

extension Notification.Name {
    static let addCompany = Notification.Name("addCompany")
}
