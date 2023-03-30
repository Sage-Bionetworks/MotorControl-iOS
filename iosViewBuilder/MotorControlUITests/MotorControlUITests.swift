//
//  MotorControlUITests.swift
//  MotorControlUITests
//
//

import XCTest
import SwiftUI

final class MotorControlUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }
    
    func testTremorBoth() throws {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(app: app, measureID: "tremor")
        handSelection(app: app, handSelection: "Skip question")
        next(app: app)
        next(app: app)
        next(app: app)
        conductMotion(app: app, nextButtonString: "Next", duration: 40)
        conductMotion(app: app, nextButtonString: "Done", duration: 40, expectedFiles: [
            "right_tremor.json",
            "left_tremor.json"
        ])
    }
    
    func testKineticTremorBoth() throws {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(app: app, measureID: "kinetic-tremor")
        next(app: app)
        handSelection(app: app, handSelection: "Skip question")
        next(app: app)
        next(app: app)
        next(app: app)
        next(app: app)
        conductMotion(app: app, nextButtonString: "Next", duration: 40)
        conductMotion(app: app, nextButtonString: "Done", duration: 40, expectedFiles: [
            "right_tremor.json",
            "left_tremor.json"
        ])
    }
    
    func testTapping() throws {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(app: app, measureID: "finger-tapping")
        next(app: app)
        handSelection(app: app, handSelection: "Skip question")
        next(app: app)
        next(app: app)
        conductTapping(app: app, nextButtonString: "Next", duration: 40)
        conductTapping(app: app, nextButtonString: "Done", duration: 40, expectedFiles: [
            "right_tapping.json",
            "left_tapping.json",
            "right_tapping",
            "left_tapping"
        ])
    }
    
    func testWalkThirtySecond() {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(app: app, measureID: "walk-thirty-second")
        next(app: app)
        next(app: app)
        next(app: app)
        next(app: app)
        conductMotion(app: app, nextButtonString: "Done", duration: 40, expectedFiles: [
            "walk_motion.json"
        ])
    }
    
    func testWalkAndBalance() {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(app: app, measureID: "walk-and-balance")
        next(app: app)
        next(app: app)
        next(app: app)
        next(app: app)
        conductMotion(app: app, nextButtonString: "Next", duration: 40)
        next(app: app)
        conductMotion(app: app, nextButtonString: "Done", duration: 40, expectedFiles: [
            "walk_motion.json",
            "balance_motion.json"
        ])
    }
    
    /**
     Helper functions
     */
    
    func checkButtonExistsAndTap(_ app: XCUIApplication, _ elementName: String) {
        let button = app.buttons[elementName]
        XCTAssert(button.exists)
        button.tap()
    }
    
    func navigatePastOverview(app: XCUIApplication, measureID: String) {
        checkButtonExistsAndTap(app, measureID)
        checkButtonExistsAndTap(app, "Get Started")
    }
    
    func handSelection(app: XCUIApplication, handSelection: String) {
        checkButtonExistsAndTap(app, handSelection)
    }
    
    func next(app: XCUIApplication) {
        checkButtonExistsAndTap(app, "Next")
    }
    
    func conductMotion(app: XCUIApplication, nextButtonString: String, duration: Double, expectedFiles: [String] = []) {
        let success = app.buttons[nextButtonString].waitForExistence(timeout: TimeInterval(floatLiteral: duration))
        XCTAssert(success)
        let nextButton = app.buttons[nextButtonString]
        XCTAssert(nextButton.exists)
        
        for filename in expectedFiles {
            let fileTextView = app.staticTexts[filename]
            XCTAssert(fileTextView.exists)
        }
        
        nextButton.tap()
    }
    
    func conductTapping(app: XCUIApplication, nextButtonString: String, duration: Double, expectedFiles: [String] = []) {
        let leftTapButton = app.buttons["LEFT_TAP"]
        let rightTapButton = app.buttons["RIGHT_TAP"]
        XCTAssert(leftTapButton.exists)
        XCTAssert(rightTapButton.exists)
        
        let buttons = [leftTapButton, rightTapButton]
        for ii in 0..<25 {
            buttons[ii%2].tap()
        }
        
        let success = app.buttons[nextButtonString].waitForExistence(timeout: TimeInterval(floatLiteral: duration))
        let nextButton = app.buttons[nextButtonString]
        XCTAssert(success)
        XCTAssert(nextButton.exists)
        
        for filename in expectedFiles {
            XCTAssert(app.staticTexts[filename].exists)
        }
        
        nextButton.tap()
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
