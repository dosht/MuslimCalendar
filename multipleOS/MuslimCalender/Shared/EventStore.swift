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
            let source = ekEventStore.sources.filter({ s in s.title == "Default" || s.title == "iCloud" }).first
            let calendar = EKCalendar(for: .event, eventStore: ekEventStore)
            calendar.source = source
            calendar.title = "Muslim Calendar"
            try! ekEventStore.saveCalendar(calendar, commit: true)
            return calendar
        }
    }
    
    @discardableResult
    func createOrUpdate(_ relativeEvent: RelativeEvent, on day: Date, prayerCalculator: PrayerCalculator, repeats: Bool = false) -> EKEvent {
        let savedEKEvent = findEKEvent(relativeEvent)
        let ekEvent = relativeEvent.transform(self, time: prayerCalculator.time, savedEKEvent: savedEKEvent)
        ekEvent.calendar = muslimCalender
        let endDate = day.nextMonth.endOfMonth
        if repeats && !ekEvent.hasRecurrenceRules {
            let end = EKRecurrenceEnd(end: endDate)
            let rule = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: end)
            ekEvent.addRecurrenceRule(rule)
        }
        let alarm = EKAlarm(relativeOffset: -10*60)
        ekEvent.addAlarm(alarm)
        try! ekEventStore.save(ekEvent, span: .futureEvents)
        relativeEvent.ekEventIdentifier = ekEvent.eventIdentifier
        if repeats {
            updateFutureEvents(relativeEvent, startFrom: day, until: endDate, location: prayerCalculator.location)
        }
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
            try? ekEventStore.remove(ekEvent, span: .futureEvents)
        }
    }
    
    func updateFutureEvents(_ relativeEvent: RelativeEvent, startFrom startDate: Date, until endDate: Date, location: CLLocationCoordinate2D) {
        let events = findFutureEvents(relativeEvent, startFrom: startDate, until: endDate)
        var today = startDate.tomorrow
        var prayerCalculator: PrayerCalculator = PrayerCalculator(location: location, date: today)!
        for event in events {
            prayerCalculator = PrayerCalculator(location: location, date: today)!
            event.startDate = relativeEvent.startDate(time: prayerCalculator.time)
            event.endDate = relativeEvent.endDate(time: prayerCalculator.time)
            try? ekEventStore.save(event, span: .thisEvent)
            today = today.tomorrow
        }
    }
    
    func findFutureEvents(_ relativeEvent: RelativeEvent, startFrom startDate: Date, until endDate: Date) -> [EKEvent] {
        let recurrenceRules = relativeEvent.getRecurrenceRules(self)
        let events = ekEventStore
            .events(matching: ekEventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [muslimCalender]))
            .filter { $0.recurrenceRules?.first == recurrenceRules.first && $0.title == relativeEvent.title }
        return events
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
    func transform(_ eventStore: EventStore, time: (TimeName) -> Date, savedEKEvent: EKEvent? = nil) -> EKEvent {
        let ekEvent = savedEKEvent ?? EKEvent(eventStore: eventStore.ekEventStore)
        ekEvent.title = self.title
        ekEvent.startDate = self.startDate(time: time)
        ekEvent.endDate = self.endDate(time: time)
        ekEvent.isAllDay = false
        return ekEvent
    }
    
    func getRecurrenceRules(_ eventStore: EventStore) -> [EKRecurrenceRule] {
        if let ekEventIdentifier = self.ekEventIdentifier {
            return eventStore.ekEventStore.event(withIdentifier: ekEventIdentifier)?.recurrenceRules ?? []
        } else {
            return []
        }
    }
    
    func startDate(time: (TimeName) -> Date) -> Date {
        return time(self.startTimeName).addingTimeInterval(self.start)
    }
    
    func endDate(time: (TimeName) -> Date) -> Date {
        return time(self.endTimeName).addingTimeInterval(self.end)
    }
}

extension Date {
    var nextMonth: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: self)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
