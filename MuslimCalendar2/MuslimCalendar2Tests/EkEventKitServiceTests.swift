//
//  EkEventKitService.swift
//  MuslimCalendar2Tests
//
//  Created by Mustafa Abdelhamıd on 4.11.2022.
//

import XCTest
import Foundation
import EventKit
@testable import MuslimCalendar2

class Tests_EventStrore: XCTestCase {
    var eventService = EventKitService()
    let ekEventStore = EKEventStore()

    override func setUpWithError() throws {
        try resetCalendar()
    }

    override func tearDownWithError() throws {
        try resetCalendar()
    }
    
    func resetCalendar() throws {
        eventService.ekEventStore = ekEventStore
        eventService.defaultCalendarName = "Test Muslim Calendar"
        eventService.requestPermissionAndCreateEventStore()
        let calendars = ekEventStore.calendars(for: .event)
        if let calendar = calendars.first(where: { cal in cal.title == "Test Muslim Calendar" }) {
            try ekEventStore.removeCalendar(calendar, commit: true)
        }
    }

    func test_create_event() {
        let date = Date()
        let item = ScheduleItem(title: "test event", startTime: date, duration: 30*60, type: .event)
        eventService.createOrUpdate(eventOf: item)
        let events = ekEventStore.events(matching: ekEventStore.predicateForEvents(withStart: date.startOfDay, end: date.endOfDay, calendars: [eventService.calendar!]))
        XCTAssertEqual(events.count, 1)
        if let event = events.first {
            XCTAssertEqual(event.title, item.title)
            XCTAssertEqual(event.startDate.ISO8601Format(), item.startTime.ISO8601Format())
            XCTAssertEqual(event.endDate.ISO8601Format(), item.endTime.ISO8601Format())
        }
    }
    
    func test_update_event() {
        let date = Date()
        var item = ScheduleItem(title: "test event", startTime: date, duration: 30*60, type: .event)
        let ekEvent = eventService.createOrUpdate(eventOf: item)
        item.wrappedEkEvent = ekEvent
        item.title = "new test event"
        item.startTime = date.addingTimeInterval(100)
        item.duration = 90*60
        eventService.createOrUpdate(eventOf: item)
        let events = ekEventStore.events(matching: ekEventStore.predicateForEvents(withStart: date.startOfDay, end: date.endOfDay, calendars: [eventService.calendar!]))
        XCTAssertEqual(events.count, 1)
        if let event = events.first {
            XCTAssertEqual(event.title, item.title)
            XCTAssertEqual(event.startDate.ISO8601Format(), item.startTime.ISO8601Format())
            XCTAssertEqual(event.endDate.ISO8601Format(), item.endTime.ISO8601Format())
        }
    }
//    func test_update_event() {
//        let viewContext = PersistenceController.preview.container.viewContext
//        let event = RelativeEvent.create(viewContext, "Test title")
//
//        let eventStore = EventKitRepository()
//        let ekEventStore = eventStore.ekEventStore
//
//        let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
//        let prayerCalculator = PrayerCalculator(location: location, date: Date())!
//
//        let ekEvent = eventStore.createOrUpdate(event, on: Date(), prayerCalculator: prayerCalculator)
//        event.ekEventIdentifier = ekEvent.eventIdentifier
//        try! viewContext.save()
//
//        eventStore.createOrUpdate(event, on: Date(), prayerCalculator: prayerCalculator)
//
//        let predicate = ekEventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().endOfDay, calendars: [eventStore.muslimCalender])
//        let events = ekEventStore.events(matching: predicate)
//
//        XCTAssertEqual(events.count, 1)
//
////        let predicateAll = ekEventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().addingTimeInterval(7*24*60*60).endOfDay, calendars: [eventStore.muslimCalender])
////        let allEvents = ekEventStore.events(matching: predicate)
////
////        XCTAssertEqual(events.count, 7)
//    }
//
//    func test_repeating_create_events() {
//        let viewContext = PersistenceController.preview.container.viewContext
//        let event = RelativeEvent.create(viewContext, "Test title")
//            .startAt(0, relativeTo: .fajr)
//            .endAt(30, relativeTo: .fajr)
//
//        let eventStore = EventKitRepository()
//        let ekEventStore = eventStore.ekEventStore
//
//        let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
//        var prayerCalculator = PrayerCalculator(location: location, date: Date())!
//
//        let ekEvent = eventStore.createOrUpdate(event, on: Date(), prayerCalculator: prayerCalculator, repeats: true)
//
//        let events = ekEventStore.events(matching: ekEventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().nextMonth.endOfMonth, calendars: [eventStore.muslimCalender]))
//
//        XCTAssertGreaterThan(events.count, 30)
//        var today = Date()
//        for event in events {
//            prayerCalculator = PrayerCalculator(location: location, date: today)!
//            XCTAssertEqual(event.startDate, prayerCalculator.time(of: .fajr))
//            XCTAssertEqual(event.endDate, prayerCalculator.time(of: .fajr).addingTimeInterval(30))
//            today = today.tomorrow
//        }
//    }
//
//    func test_findFutureEvents() {
//        let viewContext = PersistenceController.preview.container.viewContext
//        let eventStore = EventKitRepository()
//        let ekEventStore = eventStore.ekEventStore
//
//        let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
//        let prayerCalculator = PrayerCalculator(location: location, date: Date())!
//
//        let date = Date().startOfDay
//
//        let event1 = RelativeEvent.create(viewContext, "Test1")
//            .startAt(0, relativeTo: .fajr)
//            .endAt(30, relativeTo: .fajr)
//        let ekEvent1 = event1.transform(eventStore, time: prayerCalculator.time)
//        let rule1 = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: EKRecurrenceEnd(end: date.tomorrow.endOfDay))
//        ekEvent1.addRecurrenceRule(rule1)
//        ekEvent1.calendar = eventStore.muslimCalender
//        try! ekEventStore.save(ekEvent1, span: .thisEvent)
//        event1.ekEventIdentifier = ekEvent1.eventIdentifier
//
//        let event2 = RelativeEvent.create(viewContext, "Test2")
//            .startAt(30, relativeTo: .fajr)
//            .endAt(60, relativeTo: .fajr)
//        let ekEvent2 = event2.transform(eventStore, time: prayerCalculator.time)
//        let rule2 = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: EKRecurrenceEnd(end: date.tomorrow.endOfDay))
//        ekEvent2.addRecurrenceRule(rule2)
//        ekEvent2.calendar = eventStore.muslimCalender
//        try! ekEventStore.save(ekEvent2, span: .thisEvent)
//        event2.ekEventIdentifier = ekEvent2.eventIdentifier
//
//        try! viewContext.save()
//
//        let events1 = eventStore.findFutureEvents(event1, startFrom: date.startOfDay, until: date.tomorrow.endOfDay)
//
//        let events2 = eventStore.findFutureEvents(event2, startFrom: date.startOfDay, until: date.tomorrow.endOfDay)
//
//        XCTAssertEqual(events1.count, 2)
//        XCTAssertEqual(events2.count, 2)
//    }
//
//    func test_endOfNextMonth() {
//        var dateComponents = DateComponents()
//        dateComponents.year = 1999
//        dateComponents.month = 1
//        let date: Date = Calendar(identifier: .gregorian).date(from: dateComponents)!
//        dateComponents.day = 31
//        dateComponents.hour = 23
//        dateComponents.minute = 59
//        dateComponents.second = 59
//        let expectedDate = Calendar(identifier: .gregorian).date(from: dateComponents)!
//        XCTAssertEqual(date.endOfMonth, expectedDate)
//    }
//
//    func test_nextMonth() {
//        var dateComponents = DateComponents()
//        dateComponents.month = 11
//        var date = Calendar(identifier: .gregorian).date(from: dateComponents)!
//        dateComponents.month = 12
//        var expectedDate = Calendar(identifier: .gregorian).date(from: dateComponents)!
//        XCTAssertEqual(date.nextMonth, expectedDate)
//
//        dateComponents.year = 1
//        date = Calendar(identifier: .gregorian).date(from: dateComponents)!
//        dateComponents.year = 2
//        dateComponents.month = 1
//        expectedDate = Calendar(identifier: .gregorian).date(from: dateComponents)!
//        XCTAssertEqual(date.nextMonth, expectedDate)
//    }
//
//    func test_delete_event() {
//        let viewContext = PersistenceController.preview.container.viewContext
//        let event = RelativeEvent.create(viewContext, "Test title")
//
//        let eventStore = EventKitRepository()
//        let ekEventStore = eventStore.ekEventStore
//
//        let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
//        let prayerCalculator = PrayerCalculator(location: location, date: Date())!
//
//        let ekEvent = eventStore.createOrUpdate(event, on: Date(), prayerCalculator: prayerCalculator)
//        event.ekEventIdentifier = ekEvent.eventIdentifier
//        try! viewContext.save()
//
//        eventStore.delete(event)
//
//        let predicate = ekEventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().endOfDay, calendars: [eventStore.muslimCalender])
//        let events = ekEventStore.events(matching: predicate)
//
//        XCTAssertEqual(events.count, 0)
//    }
}
