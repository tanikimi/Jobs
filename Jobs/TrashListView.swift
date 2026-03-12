import SwiftUI


struct TrashListView: View {
    @State private var showingEmptyTrashConfirmation = false
    let companies: [Company]
    let onRestore: (Company) -> Void
    let onDeletePermanently: (Company) -> Void
    let onEmptyTrash: () -> Void

    var body: some View {
        List {
            ForEach(companies) { company in
                HStack(spacing: 12) {
                    FaviconView(websiteURL: company.websiteURL)
                        .id(company.websiteURL)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(company.name)
                            .font(.headline)
                        Text(company.status.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        onDeletePermanently(company)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        onRestore(company)
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    .tint(.blue)
                }
            }
        }
        .navigationTitle("最近削除した項目")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) {
                    showingEmptyTrashConfirmation = true
                } label: {
                    Text("すべて削除")
                }
                .disabled(companies.isEmpty)
                .confirmationDialog("\(companies.count)件の項目を完全に削除してよろしいですか？", isPresented: $showingEmptyTrashConfirmation) {
                    Button("削除", role: .destructive) {
                        onEmptyTrash()
                    }
                    Button("キャンセル", role: .cancel) {}
                } message: {
                    Text("この操作は取り消せません。")
                }
            }
        }
    }
}
