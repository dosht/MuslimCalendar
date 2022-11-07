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
    let prayerCalculation = PrayerCalculation.preview

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
        eventService.createOrUpdate(eventOf: item, prayerCacluation: prayerCalculation)
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
        let ekEvent = eventService.createOrUpdate(eventOf: item, prayerCacluation: prayerCalculation)
        item.wrappedEkEvent = ekEvent
        item.title = "new test event"
        item.startTime = date.addingTimeInterval(100)
        item.duration = 90*60
        eventService.createOrUpdate(eventOf: item, prayerCacluation: prayerCalculation)
        let events = ekEventStore.events(matching: ekEventStore.predicateForEvents(withStart: date.startOfDay, end: date.endOfDay, calendars: [eventService.calendar!]))
        XCTAssertEqual(events.count, 1)
        if let event = events.first {
            XCTAssertEqual(event.title, item.title)
            XCTAssertEqual(event.startDate.ISO8601Format(), item.startTime.ISO8601Format())
            XCTAssertEqual(event.endDate.ISO8601Format(), item.endTime.ISO8601Format())
        }
    }

    func test_repeating_create_events() {
        var date = Date()
        var prayerCalculation = calculatePrayerTimes(forDay: date, forLocation: PrayerCalculation.previewLocation)!
        let startDate = prayerCalculation.time(of: .fajr)
        let duration = TimeInterval(30*60)
        let item = ScheduleItem(title: "test event", startTime: startDate, duration: duration, type: .event, startRelativeTo: 1, endRelativeTo: 1, start: 0, end: duration)
        eventService.createOrUpdate(eventOf: item, prayerCacluation: prayerCalculation)
        let events = ekEventStore.events(matching: ekEventStore.predicateForEvents(withStart: date.this(.Sunday).startOfDay, end: date.nextWeek.endOfWeek.endOfDay, calendars: [eventService.calendar!]))
        
        let futureEventsCount = 14 - date.weekDay.index + 1
        XCTAssertEqual(events.count, futureEventsCount)

        events.forEach { event in
            if let startDate = prayerCalculation.calculate(for: date)?.time(of: .fajr) {
                XCTAssertEqual(event.title, item.title)
                XCTAssertEqual(event.startDate.ISO8601Format(), startDate.ISO8601Format())
                XCTAssertEqual(event.endDate.ISO8601Format(), startDate.addingTimeInterval(duration).ISO8601Format())
                date = date.tomorrow
            }
        }
    }

    func test_delete_event() {
        let date = Date()
        var item = ScheduleItem(title: "test event", startTime: date, duration: 30*60, type: .event)
        let ekEvent = eventService.createOrUpdate(eventOf: item, prayerCacluation: prayerCalculation)
        item.wrappedEkEvent = ekEvent

        eventService.delete(eventOf: item)

        let predicate = ekEventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().endOfDay, calendars: [eventService.calendar!])
        let events = ekEventStore.events(matching: predicate)

        XCTAssertEqual(events.count, 0)
    }
}
