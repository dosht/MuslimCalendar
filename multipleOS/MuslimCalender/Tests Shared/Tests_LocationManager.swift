//
//  Tests_LocationManager.swift
//  Tests Shared
//
//  Created by Mustafa Abdelhamıd on 29.06.2022.
//

import XCTest
@testable import MuslimCalender

class Tests_LocationManager: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRequestLocation() throws {
        let location = LocationManager().requestPermissionAndGetCurrentLocation()
        XCTAssertNotNil(location, "Couldn't get location")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
