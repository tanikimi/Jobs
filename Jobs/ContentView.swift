import SwiftUI

struct ContentView: View {
    @State private var store = CompanyStore()
    @State private var sidebarSelection: SidebarItem = .all
    @State private var selectedCompanies: Set<Company> = []
    @State private var isNewCompany = false

    var filteredCompanies: [Company] {
        switch sidebarSelection {
        case .all:
            return store.companies
        case .hasEvents:
            return store.companies.filter { company in
                company.events.contains { !$0.isCompleted }
            }
        case .status(let status):
            return store.companies.filter { $0.status == status }
        case .trash:
            return store.trashedCompanies
        }
    }

    func addCompany() {
        let defaultStatus: Company.Status
        if case .status(let status) = sidebarSelection {
            defaultStatus = status
        } else {
            defaultStatus = .interested
        }
        let newCompany = Company(
            name: "",
            status: defaultStatus,
            websiteURL: "",
            memo: "",
            events: []
        )
        store.add(newCompany)
        selectedCompanies = [newCompany]
        isNewCompany = true
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $sidebarSelection, store: store)
        } content: {
            if sidebarSelection == .trash {
                TrashListView(
                    companies: store.trashedCompanies,
                    onRestore: { company in
                        store.restore(company)
                        selectedCompanies = []
                    },
                    onDeletePermanently: { company in
                        store.deletePermanently(company)
                        selectedCompanies = []
                    },
                    onEmptyTrash: {
                        store.emptyTrash()
                        selectedCompanies = []
                    }
                )
            } else {
                CompanyListView(
                    companies: filteredCompanies,
                    isGrouped: sidebarSelection == .hasEvents,
                    selectedCompanies: $selectedCompanies,
                    onAdd: addCompany,
                    onDelete: { company in
                        store.delete(company)
                        selectedCompanies.remove(company)
                    },
                    sidebarSelection: sidebarSelection
                )
            }
        } detail: {
            if let company = selectedCompanies.first,
               selectedCompanies.count == 1,
               let index = store.companies.firstIndex(where: { $0.id == company.id }) {
                CompanyDetailView(company: $store.companies[index], isEditing: isNewCompany)
                    .onAppear { isNewCompany = false }
                    .id(company.id)
            } else {
                ContentUnavailableView(
                    "選択された項目なし",
                    systemImage: "person.text.rectangle.fill",
                    description: Text("就活の進捗情報を管理できます")
                )
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("編集") {}
                            .disabled(true)
                    }
                }
            }
        }
        .environment(store)
        .onReceive(NotificationCenter.default.publisher(for: .addCompany)) { _ in
            addCompany()
        }
    }
}
