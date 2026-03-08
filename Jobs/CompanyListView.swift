import SwiftUI

struct CompanyListView: View {
    let companies: [Company]
    let isGrouped: Bool
    @Binding var selectedCompany: Company?
    let onAdd: () -> Void
    let onDelete: (Company) -> Void
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .nameAsc

    enum SortOrder: String, CaseIterable {
        case nameAsc  = "企業名（昇順）"
        case nameDesc = "企業名（降順）"
    }

    var filteredCompanies: [Company] {
        var result = companies
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedStandardContains(searchText)
            }
        }
        switch sortOrder {
        case .nameAsc:  result.sort { $0.name < $1.name }
        case .nameDesc: result.sort { $0.name > $1.name }
        }
        return result
    }

    // 日付でグルーピング
    var groupedCompanies: [(date: Date, companies: [Company])] {
        var dict: [Date: [Company]] = [:]
        for company in filteredCompanies {
            for event in company.events {
                let day = Calendar.current.startOfDay(for: event.date)
                dict[day, default: []].append(company)
            }
        }
        return dict
            .map { (date: $0.key, companies: $0.value) }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        List(selection: $selectedCompany) {
            if isGrouped {
                ForEach(groupedCompanies, id: \.date) { group in
                    Section(group.date.formatted(.dateTime.year().month().day().locale(Locale(identifier: "ja_JP")))) {
                        ForEach(group.companies) { company in
                            companyRow(company)
                        }
                    }
                }
            } else {
                ForEach(filteredCompanies) { company in
                    companyRow(company)
                }
                .onDelete { _ in }
            }
        }
        .listStyle(.sidebar)
        .searchable(text: $searchText, prompt: "企業名で検索")
        .navigationTitle("企業リスト")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: onAdd) {
                    Label("追加", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) {
                    if let company = selectedCompany {
                        onDelete(company)
                    }
                } label: {
                    Label("削除", systemImage: "trash")
                }
                .disabled(selectedCompany == nil)
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Button(order.rawValue) { sortOrder = order }
                    }
                } label: {
                    Label("並び替え", systemImage: "arrow.up.arrow.down")
                }
            }
        }
    }

    @ViewBuilder
    private func companyRow(_ company: Company) -> some View {
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
        .tag(company)
        .swipeActions {
            Button(role: .destructive) {
                onDelete(company)
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}
