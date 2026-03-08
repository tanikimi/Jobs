import SwiftUI

struct ContentView: View {
    //  ダミーデータ
    @State private var store = CompanyStore()
    @State private var selectedCompany: Company?
    
    var body: some View {
        NavigationSplitView {
            CompanyListView(companies: store.companies, selectedCompany: $selectedCompany)
                .toolbar {
                    ToolbarItem {
                        Button {
                            let newCompany = Company(
                                name: "新しい企業",
                                status: .interested,
                                websiteURL: "",
                                memo: "",
                                events: []
                            )
                            store.add(newCompany)
                            selectedCompany = newCompany
                        } label: {
                            Label("追加", systemImage: "plus")
                        }
                    }
                }
        } detail: {
            if let index = store.companies.firstIndex(where: { $0.id == selectedCompany?.id }) {
                    CompanyDetailView(company: $store.companies[index])
            } else {
                Text("企業を選択してください")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
