import SwiftUI
import EventKit

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("一般", systemImage: "gear")
                }
        }
        .frame(width: 400, height: 300)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"
    @AppStorage("selectedCalendarID") private var selectedCalendarID: String = ""
    @State private var eventKit = EventKitManager()

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
