//
//  EventKitService.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 4.11.2022.
//

import Foundation
import EventKit

class EventKitService: ObservableObject {

    @Published var ekEventStore: EKEventStore
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    init() {
        self.ekEventStore = EKEventStore()
    }

    var defaultCalendarName = "Muslim Calendar"

    var calendar: EKCalendar? {
        let calendars = ekEventStore.calendars(for: .event)
        if let calendar = calendars.first(where: { cal in cal.title == defaultCalendarName }) {
            return calendar
        } else {
            let source = ekEventStore.sources.filter({ s in s.title == "Default" || s.title == "iCloud" }).first
            let calendar = EKCalendar(for: .event, eventStore: ekEventStore)
            calendar.source = source
            calendar.title = defaultCalendarName
            try! ekEventStore.saveCalendar(calendar, commit: true)
            return calendar
        }
    }

    func findEvent(of item: ScheduleItem) -> EKEvent? {
        guard let ekEventIdentifier = item.wrappedObject?.ekEventIdentifier else { return nil }
        return ekEventStore.event(withIdentifier: ekEventIdentifier)
    }

    // MARK: - Intent(s)
    func requestPermissionAndCreateEventStore() {
        switch authorizationStatus {
        case .notDetermined:
            ekEventStore.requestAccess(to: .event, completion: { [weak self] (success, error) in
                if success {
                    self?.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                    print("success")
                } else {
                    print("error while requesting permession \(String(describing: error?.localizedDescription))")
                }
            })
        case .restricted:
            print("restriced")
        case .denied:
            print("denied")
        case .authorized:
            print("authorized")
        @unknown default:
            print("unkown")
        }
    }

    //TODO: Make it async
    @discardableResult
    func createOrUpdate(eventOf item: ScheduleItem) -> EKEvent? {
        if authorizationStatus == .notDetermined {
            requestPermissionAndCreateEventStore()
        }
        if authorizationStatus != .authorized { return nil }

        let ekEvent = item.wrappedEkEvent ?? findEvent(of: item) ?? EKEvent(eventStore: ekEventStore)
        ekEvent.title = item.title
        ekEvent.startDate = item.startTime
        ekEvent.endDate = item.endTime
        ekEvent.isAllDay = false
        ekEvent.calendar = calendar
        try! ekEventStore.save(ekEvent, span: .thisEvent)
        return ekEvent
    }

    func delete(eventOf item: ScheduleItem) {
        if authorizationStatus == .notDetermined {
            requestPermissionAndCreateEventStore()
        }
        if authorizationStatus != .authorized { return }

        if let ekEvent = item.wrappedEkEvent ?? findEvent(of: item) {
            try? ekEventStore.remove(ekEvent, span: .futureEvents)
        }
    }
}
