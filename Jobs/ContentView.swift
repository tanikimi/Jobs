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
            
            List(companies, selection: $selectedCompany){ company in
                VStack(alignment: .leading) {
                    Text(company.name)
                        .font(.headline)
                    Text(company.status.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .tag(company)
            }
            .navigationTitle("企業リスト")
        } detail: {
            if let company = selectedCompany {
                VStack(alignment: .leading, spacing: 16){
                    Text(company.name)
                        .font(.largeTitle)
                        .bold()
                    
                    Text(company.status.rawValue)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    Text("メモ")
                        .font(.headline)
                    Text(company.memo.isEmpty ? "メモなし" : company.memo)
                        .foregroundStyle(company.memo.isEmpty ? .secondary : .primary)
                    
                    Spacer()
                }
                .padding(24)
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
