import SwiftUI

@main
struct JobsApp: App {
    @State private var store = CompanyStore()
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
                .environment(store)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新規企業を追加") {
                    NotificationCenter.default.post(name: .addCompany, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        WindowGroup("エントリーシート", id: "entry-sheet", for: UUID.self) { $companyID in
            if let id = companyID {
                EntrySheetView(companyID: id)
                    .environment(store)
            }
        }
        .windowResizability(.contentSize) // 内容に合わせてサイズ変更可能に

        Settings {
            SettingsView()
        }
    }
}

extension Notification.Name {
    static let addCompany = Notification.Name("addCompany")
}
