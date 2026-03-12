import SwiftUI
import EventKit
import AppKit
import UniformTypeIdentifiers

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("一般", systemImage: "gear")
                }
            AdvancedSettingsView()
                .tabItem {
                    Label("高度な設定", systemImage: "wrench.and.screwdriver")
                }
        }
        .frame(width: 450, height: 500)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"
    @AppStorage("selectedCalendarID") private var selectedCalendarID: String = ""
    @AppStorage("selectedIconName") private var selectedIconName: String = "AppIcon"
    @State private var eventKit = EventKitManager()

    let icons: [String] = ["AppIcon", "AppIcon2", "AppIcon3", "AppIcon4", "AppIcon5"]

    func loadIcon(_ name: String) -> NSImage? {
        if let url = Bundle.main.url(forResource: name, withExtension: "icon") {
            return NSImage(contentsOf: url)
        }
        return NSImage(named: name)
    }

    var body: some View {
        Form {
            Section("外観") {
                Picker("外観モード", selection: $appearanceMode) {
                    Text("デバイスに合わせる").tag("system")
                    Text("ライト").tag("light")
                    Text("ダーク").tag("dark")
                }
                .pickerStyle(.menu)
            }

            Section("アイコン") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                    ForEach(icons, id: \.self) { iconName in
                        if let image = loadIcon(iconName) {
                            Image(nsImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedIconName == iconName ? Color.accentColor : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedIconName = iconName
                                    NSApplication.shared.applicationIconImage = image
                                }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("カレンダー") {
                if eventKit.availableCalendars.isEmpty {
                    Text("カレンダーへのアクセスを許可してください")
                        .foregroundStyle(.secondary)
                    Button("アクセスを許可") {
                        Task { await eventKit.requestAccess() }
                    }
                } else {
                    Picker("追加先カレンダー", selection: $selectedCalendarID) {
                        Text("デフォルト").tag("")
                        ForEach(eventKit.availableCalendars, id: \.calendarIdentifier) { calendar in
                            Text(calendar.title).tag(calendar.calendarIdentifier)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct AdvancedSettingsView: View {
    @State private var showingExportSuccess = false
    @State private var showingExportError = false
    @State private var showingImportConfirmation = false
    @State private var showingImportSuccess = false
    @State private var showingImportError = false
    @State private var importURL: URL? = nil

    var body: some View {
        Form {
            Section("データ") {
                LabeledContent("企業情報をインポート") {
                    Button("\"ダウンロード\" からインポート") {
                        importJSON()
                    }
                }
                LabeledContent("企業情報をエクスポート") {
                    Button("\"ダウンロード\" にエクスポート") {
                        exportJSON()
                    }
                }
            }
        }
        .formStyle(.grouped)
        
        .alert("インポートしますか？", isPresented: $showingImportConfirmation) {
            Button("インポート", role: .destructive) {
                if let url = importURL {
                    performImport(from: url)
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("既存のデータは上書きされます。この操作は取り消せません。")
        }
        .alert("インポート完了", isPresented: $showingImportSuccess) {
            Button("OK") {}
        } message: {
            Text("データは正常にインポートされました。アプリを再起動すると反映されます。")
        }
        .alert("インポート失敗", isPresented: $showingImportError) {
            Button("OK") {}
        } message: {
            Text("インポートに失敗しました。正しいファイルか確認してください。")
        }
        
        .alert("エクスポート完了", isPresented: $showingExportSuccess) {
            Button("OK") {}
        } message: {
            Text("データは正常に \"ダウンロード\" にエクスポートされました。")
        }
        .alert("エクスポート失敗", isPresented: $showingExportError) {
            Button("OK") {}
        } message: {
            Text("エクスポートに失敗しました。")
        }
    }

    private func exportJSON() {
        let sourceURL = URL.documentsDirectory.appending(path: "companies.json")
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let destinationURL = downloadsURL.appending(path: "companies.json")

        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            showingExportSuccess = true
        } catch {
            print("エクスポート失敗: \(error)")
            showingExportError = true
        }
    }

    private func importJSON() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first

        if openPanel.runModal() == .OK, let url = openPanel.url {
            importURL = url
            showingImportConfirmation = true
        }
    }

    private func performImport(from url: URL) {
        let destinationURL = URL.documentsDirectory.appending(path: "companies.json")
        do {
            let data = try Data(contentsOf: url)
            _ = try JSONDecoder().decode([Company].self, from: data)
            let backupURL = URL.documentsDirectory.appending(path: "companies_backup.json")
            try? FileManager.default.removeItem(at: backupURL)
            try? FileManager.default.copyItem(at: destinationURL, to: backupURL)
            try data.write(to: destinationURL)
            showingImportSuccess = true
        } catch {
            print("インポート失敗: \(error)")
            showingImportError = true
        }
    }
}
