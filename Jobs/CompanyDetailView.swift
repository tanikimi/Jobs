import SwiftUI

struct CompanyDetailView: View {
    @Binding var company: Company

    var body: some View {
        Form {
            Section("基本情報") {
                TextField("企業名", text: $company.name)
                Picker("ステータス", selection: $company.status) {
                    ForEach(Company.Status.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                TextField("公式サイトURL", text: $company.websiteURL)
            }

            Section("メモ") {
                TextEditor(text: $company.memo)
                    .frame(minHeight: 100)
            }
        }
        .formStyle(.grouped)
        .navigationTitle(company.name)
    }
}
