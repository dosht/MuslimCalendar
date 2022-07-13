//
//  EventStore.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 19.06.2022.
//

import EventKit

struct EventStore {
    let ekEventStore: EKEventStore
    
    init() {
        self.ekEventStore = EventStore.requestPermissionAndCreateEventStore()
    }
    
    var muslimCalender: EKCalendar {
        let calendars = ekEventStore.calendars(for: .event)
        if let calendar = calendars.first(where: { cal in cal.title == "Muslim Calendar" }) {
            return calendar
        } else {
            let source = ekEventStore.sources.first
            let calendar = EKCalendar(for: .event, eventStore: ekEventStore)
            calendar.source = source
            calendar.title = "Muslim Calendar"
            try! ekEventStore.saveCalendar(calendar, commit: true)
            return calendar
        }
    }
    
    @discardableResult
    func createOrUpdate(_ relativeEvent: RelativeEvent, on day: Date, prayerCalculator: PrayerCalculator) -> EKEvent {
        let savedEKEvent = findEKEvent(relativeEvent)
        let ekEvent = relativeEvent.transform(eventStore: ekEventStore, time: prayerCalculator.time, savedEKEvent: savedEKEvent)
        ekEvent.calendar = muslimCalender
        let alarm = EKAlarm(relativeOffset: -10*60)
        ekEvent.addAlarm(alarm)
        try! ekEventStore.save(ekEvent, span: .thisEvent)
        return ekEvent
    }
    
    func findEKEvent(_ relativeEvent: RelativeEvent) -> EKEvent? {
        if let ekEventIdentifier = relativeEvent.ekEventIdentifier {
            return ekEventStore.event(withIdentifier: ekEventIdentifier)
        } else {
            return nil
        }
    }
    
    func delete(_ relativeEvent: RelativeEvent) {
        if let ekEvent = findEKEvent(relativeEvent) {
            try? ekEventStore.remove(ekEvent, span: .thisEvent)
        }
    }
    
    static func requestPermissionAndCreateEventStore() -> EKEventStore {
        let eventStore = EKEventStore()
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion: { (success, error) in
                if success {
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
        return eventStore
    }
}

extension RelativeEvent {
    func transform(eventStore: EKEventStore, time: (TimeName) -> Date, savedEKEvent: EKEvent? = nil) -> EKEvent {
        let ekEvent = savedEKEvent ?? EKEvent(eventStore: eventStore)
        ekEvent.title = self.title
        ekEvent.startDate = self.startDate(time: time)
        ekEvent.endDate = self.endDate(time: time)
        ekEvent.isAllDay = false
        return ekEvent
    }
    
    func startDate(time: (TimeName) -> Date) -> Date {
        return time(self.startTimeName).addingTimeInterval(self.start)
    }
    
    func endDate(time: (TimeName) -> Date) -> Date {
        return time(self.endTimeName).addingTimeInterval(self.end)
    }
}
