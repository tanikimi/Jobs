import SwiftUI

struct CompanyListView: View {
    let companies: [Company]
    let isGrouped: Bool
    @Binding var selectedCompany: Company?
    let onAdd: () -> Void
    let onDelete: (Company) -> Void
    @State private var searchText = ""
    @AppStorage("sortKeyRaw") private var sortKeyRaw: String = SortKey.name.rawValue
    @AppStorage("sortAscending") private var sortAscending: Bool = true

    enum SortKey: String, CaseIterable {
        case name      = "企業名"
        case favorite  = "志望度"
        case updatedAt = "編集日時"

        var icon: String {
            switch self {
            case .name:      return "textformat"
            case .favorite:  return "star"
            case .updatedAt: return "clock"
            }
        }
    }

    var sortKey: SortKey {
        get { SortKey(rawValue: sortKeyRaw) ?? .name }
        set { sortKeyRaw = newValue.rawValue }
    }

    var filteredCompanies: [Company] {
        var result = companies
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedStandardContains(searchText)
            }
        }
        switch sortKey {
        case .name:
            result.sort { sortAscending ? $0.name < $1.name : $0.name > $1.name }
        case .favorite:
            result.sort { sortAscending ? $0.favoriteLevel < $1.favoriteLevel : $0.favoriteLevel > $1.favoriteLevel }
        case .updatedAt:
            result.sort { sortAscending ? $0.updatedAt < $1.updatedAt : $0.updatedAt > $1.updatedAt }
        }
        return result
    }

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
                ForEach(Array(groupedCompanies.enumerated()), id: \.element.date) { groupIndex, group in
                    Section {
                        ForEach(Array(group.companies.enumerated()), id: \.element.id) { index, company in
                            companyRow(company)
                                .listRowSeparator(.hidden)
                        }
                    } header: {
                        Text(group.date.formatted(.dateTime.year().month().day().locale(Locale(identifier: "ja_JP"))))
                    }
                    .listSectionSeparator(.hidden)
                }
            } else {
                ForEach(filteredCompanies) { company in
                    companyRow(company)
                }
            }
        }
        .id(isGrouped)
        .listStyle(.inset)
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
                    Picker("並び替え", selection: $sortKeyRaw) {
                        ForEach(SortKey.allCases, id: \.self) { key in
                            Label(key.rawValue, systemImage: key.icon)
                                .tag(key.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()

                    Picker("順序", selection: $sortAscending) {
                        Label("昇順", systemImage: "arrow.up").tag(true)
                        Label("降順", systemImage: "arrow.down").tag(false)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
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
