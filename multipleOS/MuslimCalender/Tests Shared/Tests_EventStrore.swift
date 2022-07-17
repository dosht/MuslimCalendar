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
            .startAt(0, relativeTo: .fajr)
            .endAt(30, relativeTo: .fajr)
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
    
    func test_repeating_create_events() {
        let viewContext = PersistenceController.preview.container.viewContext
        let event = RelativeEvent.create(viewContext, "Test title")
            .startAt(0, relativeTo: .fajr)
            .endAt(30, relativeTo: .fajr)
        
        let eventStore = EventStore()
        let ekEventStore = eventStore.ekEventStore
        
        let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
        var prayerCalculator = PrayerCalculator(location: location, date: Date())!
        
        let ekEvent = eventStore.createOrUpdate(event, on: Date(), prayerCalculator: prayerCalculator, repeats: true)
       
        let events = ekEventStore.events(matching: ekEventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().nextMonth.endOfMonth, calendars: [eventStore.muslimCalender]))
        
        XCTAssertGreaterThan(events.count, 30)
        var today = Date()
        for event in events {
            prayerCalculator = PrayerCalculator(location: location, date: today)!
            XCTAssertEqual(event.startDate, prayerCalculator.time(of: .fajr))
            XCTAssertEqual(event.endDate, prayerCalculator.time(of: .fajr).addingTimeInterval(30))
            today = today.tomorrow
        }
    }
    
    func test_endOfNextMonth() {
        var dateComponents = DateComponents()
        dateComponents.year = 1999
        dateComponents.month = 1
        let date: Date = Calendar(identifier: .gregorian).date(from: dateComponents)!
        dateComponents.day = 31
        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59
        let expectedDate = Calendar(identifier: .gregorian).date(from: dateComponents)!
        XCTAssertEqual(date.endOfMonth, expectedDate)
    }
    
    func test_nextMonth() {
        var dateComponents = DateComponents()
        dateComponents.month = 11
        var date = Calendar(identifier: .gregorian).date(from: dateComponents)!
        dateComponents.month = 12
        var expectedDate = Calendar(identifier: .gregorian).date(from: dateComponents)!
        XCTAssertEqual(date.nextMonth, expectedDate)
        
        dateComponents.year = 1
        date = Calendar(identifier: .gregorian).date(from: dateComponents)!
        dateComponents.year = 2
        dateComponents.month = 1
        expectedDate = Calendar(identifier: .gregorian).date(from: dateComponents)!
        XCTAssertEqual(date.nextMonth, expectedDate)
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
