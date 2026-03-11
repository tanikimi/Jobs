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
        guard authorizationStatus == .writeOnly || authorizationStatus == .fullAccess else {
            let granted = await requestAccess()
            guard granted else { return false }
            return await addEvent(event: event, companyName: companyName)
        }

        let ekEvent = EKEvent(eventStore: store)
        ekEvent.title = "\(companyName) - \(event.title)"
        ekEvent.notes = event.url.isEmpty ? nil : event.url
        ekEvent.calendar = store.defaultCalendarForNewEvents

        if let startTime = event.startTime {
            let calendar = Calendar.current
            let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
            let baseComponents = calendar.dateComponents([.year, .month, .day], from: event.date)

            var combined = DateComponents()
            combined.year = baseComponents.year
            combined.month = baseComponents.month
            combined.day = baseComponents.day
            combined.hour = startComponents.hour
            combined.minute = startComponents.minute

            ekEvent.startDate = calendar.date(from: combined) ?? event.date
            ekEvent.isAllDay = false

            if let endTime = event.endTime {
                let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
                var endCombined = DateComponents()
                endCombined.year = baseComponents.year
                endCombined.month = baseComponents.month
                endCombined.day = baseComponents.day
                endCombined.hour = endComponents.hour
                endCombined.minute = endComponents.minute
                ekEvent.endDate = calendar.date(from: endCombined) ?? ekEvent.startDate.addingTimeInterval(3600)
            } else {
                ekEvent.endDate = ekEvent.startDate.addingTimeInterval(3600)
            }
        } else {
            ekEvent.startDate = event.date
            ekEvent.endDate = event.date
            ekEvent.isAllDay = true
        }

        do {
            try store.save(ekEvent, span: .thisEvent)
            return true
        } catch {
            print("カレンダー追加失敗: \(error)")
            return false
        }
    }
}
