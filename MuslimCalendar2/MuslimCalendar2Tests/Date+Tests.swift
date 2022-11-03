//
//  Date+Tests.swift
//  MuslimCalendar2Tests
//
//  Created by Mustafa Abdelhamıd on 1.11.2022.
//

import XCTest
@testable import MuslimCalendar2

final class Date_Tests: XCTestCase {

    func test_date_to_WeekDay() {
        XCTAssertEqual(WeekDay.allCases.map(testDay).map { $0.weekDay }, WeekDay.allCases)
    }
    
    func test_day_of_this_week() {
        XCTAssertEqual(WeekDay.allCases.map { testDay(of: .Monday).this($0) }, WeekDay.allCases.map(testDay))
    }

}

func testDay(of day: WeekDay) -> Date {
    let string = "2022-05-0\(day.index)T00:00:00Z"
    let expectedFormat = Date.ISO8601FormatStyle()
    let date = try! Date(string, strategy: expectedFormat)
    return date
}
