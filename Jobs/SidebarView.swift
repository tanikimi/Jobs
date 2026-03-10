import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem
    let store: CompanyStore
    @State private var showingEmptyTrashConfirmation = false

    var body: some View {
        List(selection: $selection) {
            Section("フィルタ") {
                HStack {
                    Label("すべて", systemImage: "tray.2")
                    Spacer()
                    badge(store.companies.count)
                }
                .tag(SidebarItem.all)

                HStack {
                    Label("日時設定あり", systemImage: "calendar")
                    Spacer()
                    badge(store.companies.filter { company in
                        company.events.contains { !$0.isCompleted }
                    }.count)
                }
                .tag(SidebarItem.hasEvents)

                HStack {
                    Label("最近削除した項目", systemImage: "trash")
                    Spacer()
                    badge(store.trashedCompanies.count)
                }
                .tag(SidebarItem.trash)
                .contextMenu {
                    Button(role: .destructive) {
                        showingEmptyTrashConfirmation = true
                    } label: {
                        Label("すべて削除", systemImage: "trash.slash")
                    }
                    .disabled(store.trashedCompanies.isEmpty)
                }
            }

            Section("ステータス") {
                ForEach(Company.Status.allCases, id: \.self) { status in
                    HStack {
                        Label(status.rawValue, systemImage: status.icon)
                        Spacer()
                        badge(store.companies.filter { $0.status == status }.count)
                    }
                    .tag(SidebarItem.status(status))
                }
            }
        }
        .navigationTitle("Jobs")
        .confirmationDialog("\(store.trashedCompanies.count)件の項目を完全に削除してよろしいですか？", isPresented: $showingEmptyTrashConfirmation) {
            Button("削除", role: .destructive) {
                store.emptyTrash()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("この操作は取り消せません。")
        }
    }

    @ViewBuilder
    private func badge(_ count: Int) -> some View {
        if count > 0 {
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.secondary.opacity(0.2))
                .clipShape(Capsule())
        }
    }
}

enum SidebarItem: Hashable {
    case all
    case hasEvents
    case status(Company.Status)
    case trash
}
