import SwiftUI
import EventKit
import AppKit

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("一般", systemImage: "gear")
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

    let icons: [String] = ["AppIcon", "AppIcon2", "AppIcon3", "AppIcon4"]

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
