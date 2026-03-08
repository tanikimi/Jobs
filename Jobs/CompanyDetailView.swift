import SwiftUI

struct CompanyDetailView: View {
    @Binding var company: Company
    @State private var isEditing: Bool
    @FocusState private var isNameFocused: Bool

    init(company: Binding<Company>, isEditing: Bool = false) {
        self._company = company
        self._isEditing = State(initialValue: isEditing)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    FaviconView(websiteURL: company.websiteURL, size: 64)
                        .id(company.websiteURL)
                    if isEditing {
                        TextField("企業名", text: $company.name)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.plain)
                            .focused($isNameFocused)
                    } else {
                        Text(company.name)
                            .font(.title)
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

                Form {
                    Section("基本情報") {
                        if isEditing {
                            Picker("ステータス", selection: $company.status) {
                                ForEach(Company.Status.allCases, id: \.self) { status in
                                    Label(status.rawValue, systemImage: status.icon)
                                        .tag(status)
                                }
                            }
                            TextField("URL", text: $company.websiteURL)
                            TextEditor(text: $company.memo)
                                .frame(minHeight: 100)
                                .scrollContentBackground(.hidden)
                                .background(.clear)
                                .lineSpacing(4)
                        } else {
                            LabeledContent("ステータス") {
                                HStack(spacing: 4) {
                                    Image(systemName: company.status.icon)
                                    Text(company.status.rawValue)
                                }
                            }
                            LabeledContent("URL") {
                                if let url = URL(string: company.websiteURL), !company.websiteURL.isEmpty {
                                    Link(company.websiteURL, destination: url)
                                } else {
                                    Text("未設定")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Text(company.memo.isEmpty ? "メモ" : company.memo)
                                .foregroundStyle(company.memo.isEmpty ? .secondary : .primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                        }
                    }

                    Section("日程") {
                        if company.events.isEmpty {
                            Text("日程なし")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach($company.events) { $event in
                                if isEditing {
                                    Section {
                                        LabeledContent("イベント名") {
                                            TextField("", text: $event.title)
                                                .multilineTextAlignment(.trailing)
                                        }
                                        DatePicker("日付", selection: $event.date, displayedComponents: .date)
                                        LabeledContent("URL") {
                                            TextField("", text: $event.url)
                                                .multilineTextAlignment(.trailing)
                                        }
                                        Button(role: .destructive) {
                                            company.events.removeAll { $0.id == event.id }
                                        } label: {
                                            Label("日程を削除", systemImage: "trash")
                                        }
                                    }
                                } else {
                                    Section {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(event.title.isEmpty ? "タイトルなし" : event.title)
                                                .font(.headline)
                                            Text(event.date.formatted(.dateTime.year().month().day().locale(Locale(identifier: "ja_JP"))))
                                                .foregroundStyle(.secondary)
                                            if !event.url.isEmpty {
                                                if let url = URL(string: event.url) {
                                                    Link(event.url, destination: url)
                                                        .font(.caption)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                    }
                    
                    if isEditing {
                        Button {
                            company.events.append(Company.Event(title: "", date: .now))
                            company.events.sort { $0.date < $1.date }
                        } label: {
                            Label("日程を追加", systemImage: "plus")
                        }
                    }
                }
                .formStyle(.grouped)
            }
        }
        .navigationTitle(company.name)
        .task {
            if isEditing {
                try? await Task.sleep(for: .milliseconds(100))
                isNameFocused = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "完了" : "編集") {
                    isEditing.toggle()
                    if isEditing {
                        isNameFocused = true
                    }
                }
            }
        }
    }
}
