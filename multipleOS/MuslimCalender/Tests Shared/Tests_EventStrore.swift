//
//  Tests_EventStrore.swift
//  Tests Shared
//
//  Created by Mustafa Abdelhamıd on 10.07.2022.
//

import XCTest
import CoreLocation
import EventKit
@testable import MuslimCalender

class Tests_EventStrore: XCTestCase {

    override func setUpWithError() throws {
        try resetCalendar()
    }

    override func tearDownWithError() throws {
        try resetCalendar()
    }
    
    func resetCalendar() throws {
        let eventStore = EventStore()
        let ekEventStore = eventStore.ekEventStore
        let calendars = ekEventStore.calendars(for: .event)
        if let calendar = calendars.first(where: { cal in cal.title == "Muslim Calendar" }) {
            try ekEventStore.removeCalendar(calendar, commit: true)
        }
    }

    func test_create_event() {
        let viewContext = PersistenceController.preview.container.viewContext
        let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
        let event = RelativeEvent.create(viewContext, "Test title")
        let eventStore = EventStore()
        let ekEventStore = eventStore.ekEventStore
        let prayerCalculator = PrayerCalculator(location: location, date: Date())!
        
        eventStore.createOrUpdate(event, on: Date(), prayerCalculator: prayerCalculator)
        
        let predicate = ekEventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().endOfDay, calendars: [eventStore.muslimCalender])
        let events = ekEventStore.events(matching: predicate)
        
        XCTAssertEqual(events.count, 1)
    }
    
    func test_update_event() {
        let viewContext = PersistenceController.preview.container.viewContext
        let event = RelativeEvent.create(viewContext, "Test title")
        
        let eventStore = EventStore()
        let ekEventStore = eventStore.ekEventStore
        
        let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
        let prayerCalculator = PrayerCalculator(location: location, date: Date())!
        
        let ekEvent = eventStore.createOrUpdate(event, on: Date(), prayerCalculator: prayerCalculator)
        event.ekEventIdentifier = ekEvent.eventIdentifier
        try! viewContext.save()
        
        eventStore.createOrUpdate(event, on: Date(), prayerCalculator: prayerCalculator)
        
        let predicate = ekEventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().endOfDay, calendars: [eventStore.muslimCalender])
        let events = ekEventStore.events(matching: predicate)
        
        XCTAssertEqual(events.count, 1)
        
//        let predicateAll = ekEventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().addingTimeInterval(7*24*60*60).endOfDay, calendars: [eventStore.muslimCalender])
//        let allEvents = ekEventStore.events(matching: predicate)
//
//        XCTAssertEqual(events.count, 7)
    }
    
    func test_weekly_create_events_try() {
        let eventStore = EventStore()
        let ekEventStore = eventStore.ekEventStore
        
        let ekEvent = EKEvent(eventStore: ekEventStore)
        ekEvent.startDate = Date()
        ekEvent.endDate = Date().addingTimeInterval(30*60)
        ekEvent.title = "test event"
        ekEvent.calendar = eventStore.muslimCalender
        let rule = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: EKRecurrenceEnd(end: Date().addingTimeInterval(7*24*60*60)))
        ekEvent.addRecurrenceRule(rule)
        
        XCTAssertEqual(ekEvent.recurrenceRules?.count, 1)
        
        try! ekEventStore.save(ekEvent, span: .thisEvent)
        
        let eventsToday = ekEventStore.events(matching: ekEventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().endOfDay, calendars: [eventStore.muslimCalender]))
        let eventsTomorrow = ekEventStore.events(matching: ekEventStore.predicateForEvents(withStart: Date().tomorrow.startOfDay, end: Date().tomorrow.endOfDay, calendars: [eventStore.muslimCalender]))
        
        print(eventsToday)
        print(eventsTomorrow)
        
        print("====================================")
        print(eventsToday.first?.recurrenceRules?.first)
        print(eventsTomorrow.first?.recurrenceRules?.first)
        print(eventsTomorrow.first?.recurrenceRules?.first == eventsToday.first?.recurrenceRules?.first)
        print("====================================")
    }
    
    func test_delete_event() {
        let viewContext = PersistenceController.preview.container.viewContext
        let event = RelativeEvent.create(viewContext, "Test title")
        
        let eventStore = EventStore()
        let ekEventStore = eventStore.ekEventStore
        
        let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
        let prayerCalculator = PrayerCalculator(location: location, date: Date())!
        
        let ekEvent = eventStore.createOrUpdate(event, on: Date(), prayerCalculator: prayerCalculator)
        event.ekEventIdentifier = ekEvent.eventIdentifier
        try! viewContext.save()
        
        eventStore.delete(event)
        
        let predicate = ekEventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().endOfDay, calendars: [eventStore.muslimCalender])
        let events = ekEventStore.events(matching: predicate)
        
        XCTAssertEqual(events.count, 0)
    }
}
