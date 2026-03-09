import SwiftUI

@main
struct JobsApp: App {
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
    }
}

extension Notification.Name {
    static let addCompany = Notification.Name("addCompany")
}
