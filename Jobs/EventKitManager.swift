import EventKit
import Foundation

@Observable
class EventKitManager {
    private let store = EKEventStore()
    var authorizationStatus: EKAuthorizationStatus = .notDetermined

    init() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }

    func requestAccess() async -> Bool {
        // print("現在の権限状態: \(EKEventStore.authorizationStatus(for: .event).rawValue)")
        do {
            let granted = try await store.requestWriteOnlyAccessToEvents()
            // print("権限リクエスト結果: \(granted)")
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            return granted
        } catch {
            // print("カレンダーアクセス失敗: \(error)")
            return false
        }
    }

    func addEvent(event: Company.Event, companyName: String) async -> Bool {
        // 権限がなければリクエスト
        if authorizationStatus != .writeOnly && authorizationStatus != .fullAccess {
            let granted = await requestAccess()
            guard granted else { return false }
        }

        let ekEvent = EKEvent(eventStore: store)
        ekEvent.title = "\(companyName) - \(event.title)"
        ekEvent.isAllDay = true
        ekEvent.startDate = event.date
        ekEvent.endDate = event.date
        ekEvent.calendar = store.defaultCalendarForNewEvents
        ekEvent.notes = event.url.isEmpty ? nil : event.url

        do {
            try store.save(ekEvent, span: .thisEvent)
            return true
        } catch {
            // print("イベント保存失敗: \(error)")
            return false
        }
    }
}
