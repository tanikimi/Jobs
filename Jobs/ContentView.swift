import SwiftUI

struct ContentView: View {
    //  ダミーデータ
    @State private var companies: [Company] = [
        Company(name: "株式会社サンプル", status: .interview,
                websiteURL: "https://example.com", memo: "志望度高め", events: []),
        Company(name: "テスト商事", status: .applied,
                websiteURL: "https://test.co.jp", memo: "", events: [])
    ]
    @State private var selectedCompany: Company?
    
    var body: some View {
        NavigationSplitView {
            CompanyListView(companies: companies, selectedCompany: $selectedCompany)
        } detail: {
            if let company = selectedCompany {
                CompanyDetailView(company: company)
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
