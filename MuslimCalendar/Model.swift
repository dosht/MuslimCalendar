//
//  Model.swift
//  MuslimCalendar
//
//  Created by Mustafa Abdelhamıd on 19.03.2022.
//

import Foundation
import EventKit
import Adhan
import KVKCalendar

struct Model {
    var events: [Event] = []
    var eventStore: EKEventStore = EventStore.requestPermissionAndCreateEventStore()
    
    mutating func initPrayerTimes() {
        let events = eventsOf(day: Date())
        if !events.isEmpty {
            self.events = events
            return
        }
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: Date())
        // 40,71910° N, 29,78066° E
        let coordinates = Coordinates(latitude: 40.71910, longitude: 29.78066)
        var params = CalculationMethod.turkey.params
        params.madhab = .shafi
        params.method = .turkey
        if let prayers = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params) {
            var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
            print(localTimeZoneIdentifier)
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.timeZone = TimeZone(identifier: localTimeZoneIdentifier)!

            addEvent(Event.create(ID: "\(Times.fajr)", text: "Fajr", duration: 60*30, start: prayers.fajr))
            addEvent(Event.create(ID: "\(Times.sunrise)", text: "Sunrise ☀️", duration: 60*30, start: prayers.sunrise))
            addEvent(Event.create(ID: "\(Times.dhur)", text: "Dhur", duration: 60*30, start: prayers.dhuhr))
            addEvent(Event.create(ID: "\(Times.asr)", text: "Asr", duration: 60*30, start: prayers.asr))
            addEvent(Event.create(ID: "\(Times.maghrib)", text: "Maghrib ", duration: 60*30, start: prayers.maghrib))
            addEvent(Event.create(ID: "\(Times.isha)", text: "Isha", duration: 60*30, start: prayers.isha))
        }
    }

    mutating func addEvent(_ event: Event) {
        let ekEvent = event.transform(eventStore: eventStore)
        ekEvent.calendar = muslimCalender
        try! eventStore.save(ekEvent, span: .thisEvent)
        events.append(event)
    }
    
    var muslimCalender: EKCalendar {
        let calendars = eventStore.calendars(for: .event)
        if let calendar = calendars.first(where: { cal in cal.title == "Muslim Calendar" }) {
            return calendar
        } else {
            let source = eventStore.sources.first
            let calendar = EKCalendar(for: .event, eventStore: eventStore)
            calendar.source = source
            calendar.title = "Muslim Calendar"
            try! eventStore.saveCalendar(calendar, commit: true)
            return calendar
        }
    }
    
    func eventsOf(day: Date) -> [Event] {
        let predicate = eventStore.predicateForEvents(withStart: day.startOfDay, end: day.endOfDay, calendars: [muslimCalender])
        return eventStore.events(matching: predicate).map { $0.transform() }
    }
}

enum Times {
    case fajr, sunrise, dhur, asr, maghrib, isha
}

extension Event: Equatable {
    public static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.ID == rhs.ID
    }
    
    public static func create(ID: String, text: String, duration: TimeInterval, start: Date) -> Event {
        var event = Event(ID: ID)
        event.text = text
        event.start = start
        event.end = Date(timeInterval: duration, since: start)
        event.isAllDay = false
        event.isContainsFile = false
        event.recurringType = .none
        return event
    }
    func eventAfter(_ name: String, for duration: TimeInterval) -> Event {
        Event.create(ID: name, text: name, duration: duration, start: self.end)
    }
    
    func eventBefore(_ name: String, for duration: TimeInterval) -> Event {
        Event.create(ID: name, text: name, duration: duration, start: Date(timeInterval: -duration, since: start))
    }
    
    func transform(eventStore: EKEventStore) -> EKEvent {
        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.title = self.text
        ekEvent.startDate = self.start
        ekEvent.endDate = self.end
        ekEvent.isAllDay = self.isAllDay
        return ekEvent
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    var endOfDay: Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }

}
