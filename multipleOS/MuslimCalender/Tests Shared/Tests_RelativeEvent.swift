//
//  Tests_Shared.swift
//  Tests Shared
//
//  Created by Mustafa Abdelhamıd on 4.06.2022.
//

import XCTest
@testable import MuslimCalender

class Tests_Shared: XCTestCase {
    let context = PersistenceController(inMemory: true).container.viewContext
    func time(_ timeName: TimeName) -> Date {
        switch timeName {
        case .midnight:
            return Date()
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
