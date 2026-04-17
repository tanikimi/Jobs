// Jobs/EntrySheetView.swift
import SwiftUI

struct EntrySheetView: View {
    let companyID: UUID
    @Environment(CompanyStore.self) private var store
    
    // 該当する企業を計算プロパティで取得
    private var companyBinding: Binding<Company>? {
        Binding(
            get: {
                store.companies.first(where: { $0.id == companyID }) ??
                Company(name: "不明", status: .interested, websiteURL: "", memo: "", events: [])
            },
            set: { newValue in
                if let index = store.companies.firstIndex(where: { $0.id == companyID }) {
                    store.companies[index] = newValue
                }
            }
        )
    }

    var body: some View {
        if let company = companyBinding {
            TextEditor(text: company.entrySheet)
                .font(.body)
                .lineSpacing(6)
                .padding()
                .frame(minWidth: 500, minHeight: 400) // ウィンドウの初期サイズ
                .navigationTitle("\(company.wrappedValue.name) のES")
                .onChange(of: company.entrySheet.wrappedValue) {
                    company.wrappedValue.updatedAt = Date.now
                }
        } else {
            Text("企業が見つかりません")
                .padding()
        }
    }
}
