import SwiftUI
import AppKit

struct EntrySheetView: View {
    let companyID: UUID
    @Environment(CompanyStore.self) private var store

    var body: some View {
        @Bindable var bindableStore = store
        
        if let index = store.companies.firstIndex(where: { $0.id == companyID }) {
            let companyBinding = $bindableStore.companies[index]
            
            List {
                ForEach(companyBinding.entrySheets) { $item in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            ZStack(alignment: .topLeading) {
                                // プレースホルダー（透かし文字）を自作して重ねる
                                if item.title.isEmpty {
                                    Text("設問タイトル (例: 志望理由)")
                                        .font(.title3.bold())
                                        .foregroundStyle(.tertiary)
//                                        .padding(.leading, 4)
                                        .padding(.top, 2)
                                        .allowsHitTesting(false) // クリックを下のTextEditorに貫通させる
                                }
                                
                                TextEditor(text: $item.title)
                                    .font(.title3.bold())
                                    .frame(height: 18)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                            }
                            // エンターキーによる改行を無効化し、1行の入力欄として振る舞わせる
                            .onChange(of: item.title) { _, newValue in
                                if newValue.contains("\n") {
                                    item.title = newValue.replacingOccurrences(of: "\n", with: "")
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(item.text, forType: .string)
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("本文をコピー")
                        }
                        
                        TextEditor(text: $item.text)
                            .font(.body)
                            .lineSpacing(6)
                            .frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                            .scrollDisabled(true)
                        
                        HStack {
                            Spacer()
                            Text("\(item.text.count) 文字")
                                .font(.caption)
                                .foregroundColor(item.text.count > 0 ? .primary : .secondary)
                        }
                    }
                    // 👇 左右の余白を追加
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            let targetID = item.id
                            withAnimation {
                                store.companies[index].entrySheets.removeAll { $0.id == targetID }
                                store.companies[index].updatedAt = Date.now
                            }
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
                
                // 追加ボタン行
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            store.companies[index].entrySheets.append(Company.EntrySheetItem())
                        }
                    } label: {
                        Label("項目を追加", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(Color.accentColor)
                    Spacer()
                }
                .padding(.vertical, 20)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle("\(companyBinding.wrappedValue.name) のエントリーシート")
            
            // 👇 画面が表示された時に項目が空なら1つ追加する
            .onAppear {
                if store.companies[index].entrySheets.isEmpty {
                    store.companies[index].entrySheets.append(Company.EntrySheetItem())
                }
            }
            .onChange(of: companyBinding.wrappedValue.entrySheets) { _, _ in
                store.companies[index].updatedAt = Date.now
            }
        } else {
            ContentUnavailableView("企業が見つかりません", systemImage: "doc.text.magnifyingglass")
        }
    }
}
