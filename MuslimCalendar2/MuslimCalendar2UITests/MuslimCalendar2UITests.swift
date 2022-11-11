

//
//  MuslimCalendar2UITests.swift
//  MuslimCalendar2UITests
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import XCTest
import CoreData

// Naming Structure: test_UnitofWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct]_[ui component]_[expected result]
// Testing Structure: Given, When, Then


/*
 func test_UITestingBootcampView_signUpButton_shouldSignIn(){
 
     // Given
     let textfield = app.textFields[ "Add your name..."]
     
     // When
     textfield.tap()
     let keyA = app.keys["A" ]
     keyA.tap()
     keyA. tap () keyA.tap()
     let returnButton = app.buttons[ "Return"]
     returnButton.tap ()
     let signUpButton = app.buttons[ "Sign Up"]
     signUpButton.tap()
     
     // Then
     let navBar = app.navigationBars [ "Welcome" ]
     XCTAssertTrue (navBar.exists)
 }
 */

final class MuslimCalendar2UITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.uninstall(name: "Muslim Planner")
    }

    func test_ScheduleView_AddEvent_CreatesNewEvent() throws {
        // UI tests must launch the application that they test.
        app.launch()
        
                
        let alert = app.alerts["Allow “Muslim Planner” to use your location?"]
        if alert.exists { alert.scrollViews.otherElements.buttons["Allow While Using App"].tap() }
        
        // Given
        let collectionViewsQuery = app.collectionViews
        let availableSlot = collectionViewsQuery.children(matching: .cell).element(boundBy: 2).children(matching: .other).element(boundBy: 1).children(matching: .other).element

        // When
        availableSlot.tap()

        let textField = collectionViewsQuery/*@START_MENU_TOKEN@*/.scrollViews/*[[".cells.scrollViews",".scrollViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.otherElements.containing(.staticText, identifier:"30m").children(matching: .textField).element
        textField.tap()

        app/*@START_MENU_TOKEN@*/.keyboards.keys["A"]/*[[".keyboards.keys[\"A\"]",".keys[\"A\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()

        app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()

        // Then
        let elementsQuery = app.collectionViews/*@START_MENU_TOKEN@*/.scrollViews/*[[".cells.scrollViews",".scrollViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.otherElements
        XCTAssertTrue(elementsQuery.staticTexts["30m"].exists)
//        XCTAssertTrue(elementsQuery.staticTexts["5:50 AM"].exists)
//        XCTAssertTrue(elementsQuery.staticTexts["6:20 AM"].exists)

        // Clean up
        let scrollViewsQuery = collectionViewsQuery/*@START_MENU_TOKEN@*/.scrollViews/*[[".cells.scrollViews",".scrollViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let element = scrollViewsQuery.otherElements.containing(.staticText, identifier:"30m").element
        element.swipeLeft()
        collectionViewsQuery.buttons["Delete"].tap()

        app.terminate()
        app.launch()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
