//
//  MuslimCalendar2Tests.swift
//  MuslimCalendar2Tests
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import XCTest
import SwiftUI
@testable import MuslimCalendar2

final class AllocationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /*
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
     */
    
    struct TestScheduleItem {
        let startTime: String
        let d: TimeInterval
        let scheduleRule: ScheduleItem.ScheduleRule
        let s: TimeInterval
        let e: TimeInterval
        let sr: Int
        let er: Int
        
        init(startTime: String, d: TimeInterval, scheduleRule: ScheduleItem.ScheduleRule, s: TimeInterval = -1, e: TimeInterval = -1, sr: Int = -1, er: Int = -1) {
            self.startTime = startTime
            self.d = d
            self.scheduleRule = scheduleRule
            self.s = s
            self.e = e
            self.sr = sr
            self.er = er
        }
        
        var item: ScheduleItem {
            ScheduleItem(title: "", startTime: Date(timeString: startTime), duration: d*60, type: .event, scheduleRule: scheduleRule, startRelativeTo: sr, endRelativeTo: er, start: s*60, end: e*60)
        }
    }
    
    struct TestAllocation {
        let startTime: String
        let endTime: String
        let s: TimeInterval
        let e: TimeInterval
        let sr: Int
        let er: Int
        
        var allocation: Allocation {
            Allocation(startTime: Date(timeString: startTime), endTime: Date(timeString: endTime), startRelativeTo: sr, start: s*60, endRelativeTo: er, end: e*60)
        }
    }

    func testCase(input: TestScheduleItem, alloc: TestAllocation, expected: TestScheduleItem) {
        var actual = input.item
        actual.reschedule(allocation: alloc.allocation)
        XCTAssertEqual(actual.startTime, expected.item.startTime)
        XCTAssertEqual(actual.duration, expected.item.duration)
        XCTAssertEqual(actual.scheduleRule, expected.item.scheduleRule)
        XCTAssertEqual(actual.start, expected.item.start  )
        XCTAssertEqual(actual.end, expected.item.end)
        XCTAssertEqual(actual.startRelativeTo, expected.item.startRelativeTo)
        XCTAssertEqual(actual.endRelativeTo, expected.item.endRelativeTo)
        
    }
    // Basic cases
    func test_reschedule_biginning() {
        testCase(input: TestScheduleItem(startTime: "04:00", d: 30, scheduleRule: .beginning),
                 alloc: TestAllocation(startTime: "04:00", endTime: "10:00", s: 0, e: 0, sr: 0, er: 1),
                 expected: TestScheduleItem(startTime: "04:00", d: 30, scheduleRule: .beginning, s: 0, e: 30, sr: 0, er: 0))
    }
    func test_reschedule_end() {
        testCase(input: TestScheduleItem(startTime: "09:30", d: 30, scheduleRule: .end),
                 alloc: TestAllocation(startTime: "04:00", endTime: "10:00", s: 0, e: 0, sr: 0, er: 1),
                 expected: TestScheduleItem(startTime: "09:30", d: 30, scheduleRule: .end, s: -30, e: -0, sr: 1, er: 1))
    }
    func test_reschedule_full() {
        testCase(input: TestScheduleItem(startTime: "04:00", d: 30, scheduleRule: .full),
                 alloc: TestAllocation(startTime: "04:00", endTime: "10:00", s: 0, e: 0, sr: 0, er: 1),
                 expected: TestScheduleItem(startTime: "04:00", d: 6*60, scheduleRule: .full, s: 0, e: 0, sr: 0, er: 1))
    }
    // Partial Beginning
    func test_reshedule_partial_biginning_biginning() {
        testCase(input: TestScheduleItem(startTime: "04:00", d: 30, scheduleRule: .beginning),
                 alloc: TestAllocation(startTime: "04:00", endTime: "06:00", s: 0, e: 2*60, sr: 0, er: 0),
                 expected: TestScheduleItem(startTime: "04:00", d: 30, scheduleRule: .beginning, s: 0, e: 30, sr: 0, er: 0))
    }
    func test_reshedule_partial_biginning_full() {
        testCase(input: TestScheduleItem(startTime: "04:00", d: 30, scheduleRule: .full),
                 alloc: TestAllocation(startTime: "04:00", endTime: "06:00", s: 0, e: 2*60, sr: 0, er: 0),
                 expected: TestScheduleItem(startTime: "04:00", d: 2*60, scheduleRule: .full, s: 0, e: 2*60, sr: 0, er: 0))
    }
    func test_reshedule_partial_biginning_end() {
        testCase(input: TestScheduleItem(startTime: "04:00", d: 30, scheduleRule: .end),
                 alloc: TestAllocation(startTime: "0:40", endTime: "06:00", s: 0, e: 2*60, sr: 0, er: 0),
                 expected: TestScheduleItem(startTime: "05:30", d: 30, scheduleRule: .end, s: 1.5*60, e: 2*60, sr: 0, er: 0))
    }
    // Partial Full
    func test_reschedule_partial_full_beginning() {
        testCase(input: TestScheduleItem(startTime: "05:00", d: 30, scheduleRule: .beginning),
                 alloc: TestAllocation(startTime: "05:00", endTime: "09:00", s: 60, e: -60, sr: 0, er: 1),
                 expected: TestScheduleItem(startTime: "05:00", d: 30, scheduleRule: .beginning, s: 60, e: 90, sr: 0, er: 0))
    }
    func test_reschedule_partial_full_full() {
        testCase(input: TestScheduleItem(startTime: "05:00", d: 30, scheduleRule: .full),
                 alloc: TestAllocation(startTime: "05:00", endTime: "09:00", s: 60, e: -60, sr: 0, er: 1),
                 expected: TestScheduleItem(startTime: "05:00", d: 4*60, scheduleRule: .full, s: 60, e: -60, sr: 0, er: 1))
    }
    func test_reschedule_partial_full_end() {
        testCase(input: TestScheduleItem(startTime: "05:00", d: 30, scheduleRule: .end),
                 alloc: TestAllocation(startTime: "05:00", endTime: "09:00", s: 60, e: -60, sr: 0, er: 1),
                 expected: TestScheduleItem(startTime: "08:30", d: 30, scheduleRule: .end, s: -90, e: -60, sr: 1, er: 1))
    }
    // Partial End
    func test_reschedule_partial_end_beginning() {
        testCase(input: TestScheduleItem(startTime: "08:00", d: 30, scheduleRule: .beginning),
                 alloc: TestAllocation(startTime: "08:00", endTime: "10:00", s: -2*60, e: 0, sr: 1, er: 1),
                 expected: TestScheduleItem(startTime: "08:00", d: 30, scheduleRule: .beginning, s: -2*60, e: -1.5*60, sr: 1, er: 1))
    }
    func test_reschedule_partial_end_full() {
        testCase(input: TestScheduleItem(startTime: "08:00", d: 30, scheduleRule: .full),
                 alloc: TestAllocation(startTime: "08:00", endTime: "10:00", s: -2*60, e: 0, sr: 1, er: 1),
                 expected: TestScheduleItem(startTime: "08:00", d: 2*60, scheduleRule: .full, s: -2*60, e: 0, sr: 1, er: 1))
    }
    func test_reschedule_partial_end_end() {
        testCase(input: TestScheduleItem(startTime: "08:00", d: 30, scheduleRule: .end),
                 alloc: TestAllocation(startTime: "08:00", endTime: "10:00", s: -2*60, e: 0, sr: 1, er: 1),
                 expected: TestScheduleItem(startTime: "09:30", d: 30, scheduleRule: .end, s: -30, e: 0, sr: 1, er: 1))
    }
}
