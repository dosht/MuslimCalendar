//
//  MuslimCalendarTests.swift
//  MuslimCalendarTests
//
//  Created by Mustafa Abdelhamıd on 6.03.2022.
//

import XCTest
@testable import MuslimCalendar
import KVKCalendar

class MuslimCalendarTests: XCTestCase {
    var testEvents: [Event] = []
    var plan: Model.Plan?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        populateTestEvents()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let eventStore = EventStore.requestPermissionAndCreateEventStore()
        let calendars = eventStore.calendars(for: .event)
        if let calendar = calendars.first(where: { cal in cal.title == "Muslim Calendar" }) {
            try! eventStore.removeCalendar(calendar, commit: true)
        }
    }
    
    func populateTestEvents() {
        let model = Model()
        testEvents = model.events
        
        plan = Model.Plan(
            x: nil, rules: [
                Model.Times.fajr.rawValue: Model.ConnectedEvent(title: "Zikr", isAfter: true, duration: 15*60),
                "Zikr": Model.ConnectedEvent(title: "Quran", isAfter: true, duration: 30*60),
                Model.Times.asr.rawValue: Model.ConnectedEvent(title: "Zikr Eveneing", isAfter: true, duration: 15*60),
                Model.Times.maghrib.rawValue: Model.ConnectedEvent(title: "dua", isAfter: false, duration: 15*60),
                "dua": Model.ConnectedEvent(title: "Workout", isAfter: false, duration: 30*60),
                Model.Times.isha.rawValue: Model.ConnectedEvent(title: "Tarawih", isAfter: true, duration: 60*60)
            ]
        )
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testModel() {
        var model = Model()
        model.initPrayerTimes()
        XCTAssertEqual(model.events.count, 6, "Row count was not zero.")
        model.initPrayerTimes()
        XCTAssertEqual(model.events.count, 6, "Row count was not zero.")
    }
    
    func testSaveLoadPlan() {
        var model = Model()
        model.plan = plan
        model.savePlan()
        model.loadPlan()
        XCTAssertEqual(model.plan, plan)
    }
    
    func testApplyPlan() {
        var model = Model()
        model.plan = plan
        model.initPrayerTimes()
        model.applyPlan()
        XCTAssertEqual(model.events.count, 6+6)
        model.applyPlan()
        XCTAssertEqual(model.events.count, 6+6)
    }
    
    func testConnectEvents() {
        var model = Model()
        model.initPrayerTimes()
        let fajr = model.events.first!
        let event = fajr.eventAfter("test", for: 15*60)
        model.connect(event, with: fajr, isAfter: true, duration: 15*60)
        let expectedPlan = Model.Plan(x: nil, rules: [fajr.text: Model.ConnectedEvent(title: event.text, isAfter: true, duration: 15*60)])
        XCTAssertEqual(model.plan, expectedPlan)
    }
    
    func testConnectEventsIfAlreadyConnected() {
        var model = Model()
        model.initPrayerTimes()
        let fajr = model.events.first!
        
        // Connect the first event
        let event = fajr.eventAfter("test", for: 15*60)
        model.connect(event, with: fajr, isAfter: true, duration: 15*60)
        
        // Connect a second event
        let event2 = fajr.eventAfter("test 2", for: 15*60)
        model.connect(event2, with: fajr, isAfter: true, duration: 15*60)
        
        // Test
        let expectedPlan = Model.Plan(x: nil, rules: [
            fajr.text: Model.ConnectedEvent(title: event2.text, isAfter: true, duration: 15*60),
            event2.text: Model.ConnectedEvent(title: event.text, isAfter: true, duration: 15*60)
        ])
        XCTAssertEqual(model.plan, expectedPlan)
    }
    
    func testTomorrow() {
        let today = Date()
        let tomorrow = today.tomorrow
        XCTAssertEqual(today.day+1, tomorrow.day)
    }
}
