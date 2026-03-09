import SwiftUI

struct CompanyDetailView: View {
    @Binding var company: Company
    @State private var isEditing: Bool
    @FocusState private var isNameFocused: Bool
    @State private var eventKit = EventKitManager()
    @State private var addedEventIDs: Set<UUID> = []
    @State private var previousURL: String = ""
    @Environment(CompanyStore.self) private var store

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
                    basicInfoSection()
                    linksSection()
                    scheduleSection()
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
        .onChange(of: company.id) {
            isEditing = false
        }
        .onAppear {
            previousURL = company.websiteURL
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "完了" : "編集") {
                    if isEditing && company.name.trimmingCharacters(in: .whitespaces).isEmpty {
                        isNameFocused = true
                    } else {
                        isEditing.toggle()
                        if isEditing {
                            isNameFocused = true
                            previousURL = company.websiteURL
                        } else {
                            company.updatedAt = Date.now
                            if previousURL != company.websiteURL {
                                store.faviconCache.removeValue(forKey: previousURL)
                                Task {
                                    await store.fetchFavicon(for: company.websiteURL)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func basicInfoSection() -> some View {
        Section("基本情報") {
            if isEditing {
                Picker("ステータス", selection: $company.status) {
                    ForEach(Company.Status.allCases, id: \.self) { status in
                        Label(status.rawValue, systemImage: status.icon)
                            .tag(status)
                    }
                }
                .contentShape(Rectangle())
                LabeledContent("志望度") {
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { level in
                            Image(systemName: level <= company.favoriteLevel ? "star.fill" : "star")
                                .foregroundStyle(level <= company.favoriteLevel ? .yellow : .secondary)
                                .onTapGesture {
                                    company.favoriteLevel = level == company.favoriteLevel ? 0 : level
                                }
                        }
                    }
                }
                TextField("公式サイトURL", text: $company.websiteURL)
                    .contentShape(Rectangle())
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
                LabeledContent("志望度") {
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { level in
                            Image(systemName: level <= company.favoriteLevel ? "star.fill" : "star")
                                .foregroundStyle(level <= company.favoriteLevel ? .yellow : .secondary)
                        }
                    }
                }
                LabeledContent("公式サイトURL") {
                    if let url = URL(string: company.websiteURL), !company.websiteURL.isEmpty {
                        Link(company.websiteURL, destination: url)
                    } else {
                        Text("未設定")
                            .foregroundStyle(.secondary)
                    }
                }
                if company.memo.isEmpty {
                    Text("メモ")
                        .foregroundStyle(.secondary)
                } else {
                    Text(.init(company.memo))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func linksSection() -> some View {
        Section("リンク") {
            if company.links.isEmpty && !isEditing {
                Text("リンクなし")
                    .foregroundStyle(.secondary)
            } else {
                ForEach($company.links) { $link in
                    if isEditing {
                        Section {
                            TextField("タイトル", text: $link.title)
                            TextField("URL", text: $link.url)
                            Button(role: .destructive) {
                                company.links.removeAll { $0.id == link.id }
                            } label: {
                                Label("リンクを削除", systemImage: "trash")
                            }
                        }
                    } else {
                        LabeledContent(link.title.isEmpty ? "リンク" : link.title) {
                            if let url = URL(string: link.url), !link.url.isEmpty {
                                Link(link.url, destination: url)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            } else {
                                Text("未設定")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }

        if isEditing {
            Button {
                company.links.append(Company.Link(title: "", url: ""))
            } label: {
                Label("リンクを追加", systemImage: "plus")
            }
        }
    }

    @ViewBuilder
    private func eventRow(event: Binding<Company.Event>) -> some View {
        if isEditing {
            Section {
                TextField("イベント名", text: event.title)
                    .multilineTextAlignment(.trailing)
                    .contentShape(Rectangle())
                DatePicker("日付", selection: event.date, displayedComponents: .date)
                    .contentShape(Rectangle())
                TextField("URL", text: event.url)
                    .multilineTextAlignment(.trailing)
                    .contentShape(Rectangle())
                .contentShape(Rectangle())
                Button(role: .destructive) {
                    company.events.removeAll { $0.id == event.wrappedValue.id }
                } label: {
                    Label("日程を削除", systemImage: "trash")
                }
            }
        } else {
            HStack(alignment: .center, spacing: 12) {
                Button {
                    event.wrappedValue.isCompleted.toggle()
                } label: {
                    Image(systemName: event.wrappedValue.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(event.wrappedValue.isCompleted ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tint))
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text(event.wrappedValue.title.isEmpty ? "タイトルなし" : event.wrappedValue.title)
                        .font(.headline)
                        .foregroundStyle(event.wrappedValue.isCompleted ? .secondary : .primary)
                    Text(event.wrappedValue.date.formatted(.dateTime.year().month().day().locale(Locale(identifier: "ja_JP"))))
                        .foregroundStyle(.secondary)
                    if !event.wrappedValue.url.isEmpty {
                        if let url = URL(string: event.wrappedValue.url) {
                            Link(event.wrappedValue.url, destination: url)
                                .font(.caption)
                        }
                    }
                }
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .contextMenu {
                    Button {
                        Task {
                            let success = await eventKit.addEvent(event: event.wrappedValue, companyName: company.name)
                            if success {
                                addedEventIDs.insert(event.wrappedValue.id)
                            }
                        }
                    } label: {
                        Label(
                            addedEventIDs.contains(event.wrappedValue.id) ? "追加済み" : "カレンダーに追加",
                            systemImage: addedEventIDs.contains(event.wrappedValue.id) ? "checkmark" : "calendar.badge.plus"
                        )
                    }
                    .disabled(addedEventIDs.contains(event.wrappedValue.id))
                }
            }
        }
    }

    @ViewBuilder
    private func scheduleSection() -> some View {
        Section("日程") {
            if company.events.isEmpty && !isEditing {
                Text("日程なし")
                    .foregroundStyle(.secondary)
            } else {
                ForEach($company.events) { $event in
                    eventRow(event: $event)
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
}
