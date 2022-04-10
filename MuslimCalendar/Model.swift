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
import CoreData

struct Model {
    var events: [Event] = []
    var eventStore: EKEventStore = EventStore.requestPermissionAndCreateEventStore()
    var plan: Plan?
    private var nsManagedPlan: NSManagedObject?
    
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
            addEvent(Event.create(ID: "\(Times.maghrib)", text: "Maghrib", duration: 60*30, start: prayers.maghrib))
            addEvent(Event.create(ID: "\(Times.isha)", text: "Isha", duration: 60*30, start: prayers.isha))
        }
    }

    mutating func addEvent(_ event: Event) {
        if eventsOf(day: Date()).contains(where: { e in e.text == event.text }) {
            return
        }
        let ekEvent = event.transform(eventStore: eventStore)
        ekEvent.calendar = muslimCalender
        let alarm = EKAlarm(relativeOffset: -10*60)
        ekEvent.addAlarm(alarm)
        try! eventStore.save(ekEvent, span: .thisEvent)
        events.append(event)
    }
    
    mutating func applyPlan() {
        var queue = events.map { $0.text }
        while let node = queue.popLast() {
            if let e = plan?.rules[node] {
                queue.append(e.title)
                print(node)
                if let event = events.first(where: { e in e.text == node }) {
                    let newEvent = e.isAfter ? event.eventAfter(e.title, for: e.duration) : event.eventBefore(e.title, for: e.duration)
                    addEvent(newEvent)
                }
            }
        }
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
    
    func getPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }
    
    lazy var persistentContainer: NSPersistentContainer = getPersistentContainer()
    
    // TODO: Make sure it always keeps one object
    mutating func savePlan() {
        let context = persistentContainer.viewContext
        let object = nsManagedPlan ?? {
            let entity = NSEntityDescription.entity(forEntityName: "EventRules", in: context)
            return NSManagedObject(entity: entity!, insertInto: context)
        }()
        do {
            let jsonEncoder = JSONEncoder()
            let planData = try jsonEncoder.encode(plan!)
            let planString = String(data: planData, encoding: .utf8)!
            print("PLAN STRING: \(planString)")
            object.setValue(planString, forKey: "plan")
            try context.save()
        } catch {
            print(error)
        }
    }
    
    mutating func loadPlan() {
        let context = persistentContainer.viewContext
        if let results = try? context.fetch(NSFetchRequest(entityName: "EventRules")) as? [NSManagedObject] {
            if let result = results.last {
                nsManagedPlan = result
                let planString = result.value(forKey: "plan") as! String
                let jsonData = Data(planString.utf8)
                plan = try? JSONDecoder().decode(Plan.self, from: jsonData)
            } else {
                plan = nil
            }
        }
    }
    
    mutating func connect(_ event: Event, with connectedEvent: Event, isAfter: Bool, duration: TimeInterval) {
        if plan == nil {
            plan = Plan()
        }
        if let previousConnection = plan?.rules[connectedEvent.text] {
            plan?.rules[connectedEvent.text] = ConnectedEvent(title: event.text, isAfter: isAfter, duration: duration)
            plan?.rules[event.text] = ConnectedEvent(title: previousConnection.title, isAfter: isAfter, duration: duration)
        } else {
            plan?.rules[connectedEvent.text] = ConnectedEvent(title: event.text, isAfter: isAfter, duration: duration)
        }
    }
    
    struct Plan: Equatable, Codable {
        var x: String?
        var rules: [String: ConnectedEvent] = [:]
    }
    
    struct ConnectedEvent: Equatable, Codable {
        let title: String
        let isAfter: Bool
        let duration: TimeInterval
    }
    
    enum Times: String, CaseIterable {
        case fajr = "Fajr",
             sunrise = "Sunrise ☀️",
             dhur = "Dhur",
             asr = "Asr",
             maghrib = "Maghrib",
             isha = "Isha"
    }


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
    var tomorrow: Date {
        return Date(timeInterval: 1, since: endOfDay)
    }
}
