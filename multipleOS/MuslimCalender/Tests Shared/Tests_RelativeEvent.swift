//
//  Tests_Shared.swift
//  Tests Shared
//
//  Created by Mustafa Abdelhamıd on 4.06.2022.
//

import CoreLocation
import SwiftUI
import XCTest
@testable import MuslimCalender

class Tests_Duration: XCTestCase {
    let context = PersistenceController(inMemory: true).container.viewContext
    func time(_ timeName: TimeName) -> Date {
        switch timeName {
        case .midnight:
            return Date().startOfDay
        case .fajr:
            return Date(timeInterval: 60, since: time(.midnight))
        case .sunrise:
            return Date(timeInterval: 60, since: time(.fajr))
        case .dhur:
            return Date(timeInterval: 60, since: time(.sunrise))
        case .asr:
            return Date(timeInterval: 60, since: time(.dhur))
        case .maghrib:
            return Date(timeInterval: 60, since: time(.asr))
        case .isha:
            return Date(timeInterval: 60, since: time(.maghrib))
        case .endOfDay:
            return Date().endOfDay
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDuration() {
        let event = RelativeEvent.create(context).startAt(0, relativeTo: .fajr).endAt(10, relativeTo: .fajr)
        XCTAssertEqual(event.duration(time: time), 10)
    }
    
    func testDurationbeforeandafter() {
        let event = RelativeEvent.create(context).startAt(-10, relativeTo: .fajr).endAt(10, relativeTo: .fajr)
        XCTAssertEqual(event.duration(time: time), 20)
    }
    
    func testDurationbeBetweenTimes() {
        let event = RelativeEvent.create(context).startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise)
        XCTAssertEqual(event.duration(time: time), 60)
    }
}

class Test_AllocateEvent: XCTestCase {
    let context = PersistenceController(inMemory: true).container.viewContext
    
    func testAllocateEventAtBeginning() {
        let alloc = RelativeEvent.create(context).startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise).isAllocatable(true)
        let newEvent = RelativeEvent.create(context, "new event").startAt(0, relativeTo: .fajr).endAt(30, relativeTo: .fajr)
        alloc.allocate(newEvent: newEvent)
        
        XCTAssertEqual(alloc.startTimeName, .fajr)
        XCTAssertEqual(alloc.start, 30)
        XCTAssertEqual(alloc.endTimeName, .sunrise)
        XCTAssertEqual(alloc.end, 0)
    }
    
    func testAllocateEventAtEnd() {
        let alloc = RelativeEvent.create(context).startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise).isAllocatable(true)
        let newEvent = RelativeEvent.create(context, "new event").startAt(-30, relativeTo: .sunrise).endAt(0, relativeTo: .sunrise)
        alloc.allocate(newEvent: newEvent)
        
        XCTAssertEqual(alloc.startTimeName, .fajr)
        XCTAssertEqual(alloc.start, 0)
        XCTAssertEqual(alloc.endTimeName, .sunrise)
        XCTAssertEqual(alloc.end, -30)
    }
    
    func testAllocateFull() {
        let alloc = RelativeEvent.create(context).startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise).isAllocatable(true)
        let newEvent = RelativeEvent.create(context, "new event").startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise)
        alloc.allocate(newEvent: newEvent)
        
        XCTAssertEqual(alloc.startTimeName, .fajr)
        XCTAssertEqual(alloc.start, 0)
        XCTAssertEqual(alloc.endTimeName, .fajr)
        XCTAssertEqual(alloc.end, 0)
    }
}

class Tests_RelativeEventViewModel: XCTestCase {
    let context = PersistenceController.preview.container.viewContext
    let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
    
    // Test get
    
    func test_default_allocationType() {
        let viewModel = RelativeEventsViewModel(context: context, location: location)
        XCTAssertEqual(viewModel.allocationType, .begnning)
    }
    
    func test_start_allocationType() {
        let viewModel = RelativeEventsViewModel(context: context, location: location)
        let alloc = RelativeEvent.create(context, "").isAllocatable(true).startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise)
        viewModel.chosenAllocatableSlot = alloc
        viewModel.editedEvent = RelativeEvent.create(context, "event").startAt(0, relativeTo: alloc.startTimeName).endAt(30, relativeTo: alloc.startTimeName)
        
        XCTAssertEqual(viewModel.allocationType, .begnning)
    }
    
    func test_end_allocationType() {
        let viewModel = RelativeEventsViewModel(context: context, location: location)
        let alloc = RelativeEvent.create(context, "").isAllocatable(true).startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise)
        viewModel.chosenAllocatableSlot = alloc
        viewModel.editedEvent = RelativeEvent.create(context, "event").startAt(0, relativeTo: alloc.endTimeName).endAt(30, relativeTo: alloc.endTimeName)
        
        XCTAssertEqual(viewModel.allocationType, .end)
    }
    
    func test_full_allocationType() {
        let viewModel = RelativeEventsViewModel(context: context, location: location)
        let alloc = RelativeEvent.create(context, "").isAllocatable(true).startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise)
        viewModel.chosenAllocatableSlot = alloc
        viewModel.editedEvent = RelativeEvent.create(context, "event").startAt(0, relativeTo: alloc.startTimeName).endAt(0, relativeTo: alloc.endTimeName)
        
        XCTAssertEqual(viewModel.allocationType, .full)
    }
   
    // Test set
    
    func test_set_beginning() {
        let viewModel = RelativeEventsViewModel(context: context, location: location)
        let alloc = RelativeEvent.create(context, "").isAllocatable(true).startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise)
        viewModel.chosenAllocatableSlot = alloc
        viewModel.editedEvent = RelativeEvent.create(context, "event").startAt(0, relativeTo: alloc.endTimeName).endAt(-30, relativeTo: alloc.endTimeName)
        viewModel.newEventDuration = 30
        viewModel.allocationType = .begnning
        let editedEvent = viewModel.editedEvent!
        
        XCTAssertEqual(editedEvent.startTimeName, alloc.startTimeName)
        XCTAssertEqual(editedEvent.endTimeName, alloc.startTimeName)
        XCTAssertEqual(editedEvent.start, alloc.start)
        XCTAssertEqual(editedEvent.end, alloc.start + 30)
    }
    
    func test_set_end() {
        let viewModel = RelativeEventsViewModel(context: context, location: location)
        let alloc = RelativeEvent.create(context, "").isAllocatable(true).startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise)
        viewModel.chosenAllocatableSlot = alloc
        viewModel.editedEvent = RelativeEvent.create(context, "event").startAt(0, relativeTo: alloc.startTimeName).endAt(30, relativeTo: alloc.startTimeName)
        viewModel.newEventDuration = 30
        viewModel.allocationType = .end
        let editedEvent = viewModel.editedEvent!
        
        XCTAssertEqual(editedEvent.startTimeName, alloc.endTimeName)
        XCTAssertEqual(editedEvent.endTimeName, alloc.endTimeName)
        XCTAssertEqual(editedEvent.start, alloc.end - 30)
        XCTAssertEqual(editedEvent.end, alloc.end)
    }
    
    func test_set_full() {
        let viewModel = RelativeEventsViewModel(context: context, location: location)
        let alloc = RelativeEvent.create(context, "").isAllocatable(true).startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise)
        viewModel.chosenAllocatableSlot = alloc
        viewModel.editedEvent = RelativeEvent.create(context, "event").startAt(300, relativeTo: alloc.endTimeName).endAt(30, relativeTo: alloc.startTimeName)
        viewModel.allocationType = .full
        let editedEvent = viewModel.editedEvent!
        
        XCTAssertEqual(editedEvent.startTimeName, alloc.startTimeName)
        XCTAssertEqual(editedEvent.endTimeName, alloc.endTimeName)
        XCTAssertEqual(editedEvent.start, alloc.start)
        XCTAssertEqual(editedEvent.end, alloc.end)
    }
}
