//
//  Tests_EventStrore.swift
//  Tests Shared
//
//  Created by Mustafa Abdelhamıd on 10.07.2022.
//

import XCTest
import CoreLocation
@testable import MuslimCalender

class Tests_EventStrore: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
    
}
