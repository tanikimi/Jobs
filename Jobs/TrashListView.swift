import SwiftUI

struct TrashListView: View {
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
        .navigationTitle("ゴミ箱")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("ゴミ箱を空にする") {
                    onEmptyTrash()
                }
                .disabled(companies.isEmpty)
            }
        }
    }
}
