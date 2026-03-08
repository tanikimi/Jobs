import SwiftUI

struct ContentView: View {
    @State private var store = CompanyStore()
    @State private var sidebarSelection: SidebarItem = .all
    @State private var selectedCompany: Company?
    @State private var isNewCompany = false

    var filteredCompanies: [Company] {
        switch sidebarSelection {
        case .all:
            return store.companies
        case .hasEvents:
            return store.companies.filter { !$0.events.isEmpty }
        case .status(let status):
            return store.companies.filter { $0.status == status }
        case .trash:
            return store.trashedCompanies
        }
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $sidebarSelection)
        } content: {
            if sidebarSelection == .trash {
                TrashListView(
                    companies: store.trashedCompanies,
                    onRestore: { company in
                        store.restore(company)
                        selectedCompany = nil
                    },
                    onDeletePermanently: { company in
                        store.deletePermanently(company)
                        selectedCompany = nil
                    },
                    onEmptyTrash: {
                        store.emptyTrash()
                        selectedCompany = nil
                    }
                )
            } else {
                CompanyListView(
                    companies: filteredCompanies,
                    isGrouped: sidebarSelection == .hasEvents,
                    selectedCompany: $selectedCompany,
                    onAdd: {
                        let newCompany = Company(
                            name: "",
                            status: .interested,
                            websiteURL: "",
                            memo: "",
                            events: []
                        )
                        store.add(newCompany)
                        selectedCompany = newCompany
                        isNewCompany = true
                    },
                    onDelete: { company in
                        store.delete(company)
                        if selectedCompany == company {
                            selectedCompany = nil
                        }
                    }
                )
            }
        } detail: {
            if let index = store.companies.firstIndex(where: { $0.id == selectedCompany?.id }) {
                CompanyDetailView(company: $store.companies[index], isEditing: isNewCompany)
                    .onAppear { isNewCompany = false }
            } else {
                ContentUnavailableView("企業を選択してください", systemImage: "building.2")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("編集") {}
                                .disabled(true)
                        }
                    }
            }
        }
    }
}
