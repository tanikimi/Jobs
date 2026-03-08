import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem

    var body: some View {
        List(selection: $selection) {
            Section("Jobs") {
                Label("すべて", systemImage: "tray.2")
                    .tag(SidebarItem.all)
                Label("日時設定あり", systemImage: "calendar")
                    .tag(SidebarItem.hasEvents)
                Label("最近削除した項目", systemImage: "trash")
                        .tag(SidebarItem.trash)
            }

            Section("ステータス") {
                ForEach(Company.Status.allCases, id: \.self) { status in
                    Label(status.rawValue, systemImage: status.icon)
                        .tag(SidebarItem.status(status))
                }
            }
        }
        .navigationTitle("Jobs")
    }
}

enum SidebarItem: Hashable {
    case all
    case hasEvents
    case status(Company.Status)
    case trash
}
