//
//  MotorControlUITests.swift
//  MotorControlUITests
//
//

import XCTest

final class MotorControlUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }
    
    func testTremorBoth() throws {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(
            app,
            measureId: "tremor",
            expectedImages: ["hold_phone_left", "comfortable_place_to_sit"])
        handSelectionBoth(app)
        next(app)
        next(app)
        next(app)
        conductMotion(app, nextButtonString: "Next", duration: 40)
        conductMotion(app, nextButtonString: "Exit", duration: 40, expectedFiles: [
            "right_tremor.json",
            "left_tremor.json"
        ])
    }
    
    func testTremorLeft() throws {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(
            app,
            measureId: "tremor",
            expectedImages: ["hold_phone_left", "comfortable_place_to_sit"])
        handSelectionLeftOrRight(app, hand: "LEFT")
        next(app)
        next(app)
        next(app)
        conductMotion(app, nextButtonString: "Exit", duration: 40, expectedFiles: [
            "left_tremor.json"
        ])
    }
    
    func testTremorRight() throws {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(
            app,
            measureId: "tremor",
            expectedImages: ["hold_phone_left", "comfortable_place_to_sit"])
        handSelectionLeftOrRight(app, hand: "RIGHT")
        next(app)
        next(app)
        next(app)
        conductMotion(app, nextButtonString: "Exit", duration: 40, expectedFiles: [
            "right_tremor.json"
        ])
    }
    
    func testKineticTremorBoth() throws {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(
            app,
            measureId: "kinetic-tremor",
            expectedImages: ["kinetic_hold_phone_left", "space_to_move_your_arms", "comfortable_place_to_sit"])
        next(app)
        handSelectionBoth(app)
        next(app)
        next(app)
        next(app)
        next(app)
        conductMotion(app, nextButtonString: "Next", duration: 40)
        conductMotion(app, nextButtonString: "Exit", duration: 40, expectedFiles: [
            "right_tremor.json",
            "left_tremor.json"
        ])
    }
    
    func testKineticTremorLeft() throws {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(
            app,
            measureId: "kinetic-tremor",
            expectedImages: ["kinetic_hold_phone_left", "space_to_move_your_arms", "comfortable_place_to_sit"])
        next(app)
        handSelectionLeftOrRight(app, hand: "LEFT")
        next(app)
        next(app)
        next(app)
        next(app)
        conductMotion(app, nextButtonString: "Exit", duration: 40, expectedFiles: [
            "left_tremor.json"
        ])
    }
    
    func testKineticTremorRight() throws {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(
            app,
            measureId: "kinetic-tremor",
            expectedImages: ["kinetic_hold_phone_left", "space_to_move_your_arms", "comfortable_place_to_sit"])
        next(app)
        handSelectionLeftOrRight(app, hand: "RIGHT")
        next(app)
        next(app)
        next(app)
        next(app)
        conductMotion(app, nextButtonString: "Exit", duration: 40, expectedFiles: [
            "right_tremor.json"
        ])
    }
    
    func testTappingBoth() throws {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(
            app,
            measureId: "finger-tapping",
            expectedImages: ["tap_left_1", "flat_surface"])
        next(app)
        handSelectionBoth(app)
        next(app)
        next(app)
        conductTapping(app, nextButtonString: "Next", duration: 40)
        conductTapping(app, nextButtonString: "Exit", duration: 40, expectedFiles: [
            "right_tapping.json",
            "left_tapping.json",
            "right_tapping",
            "left_tapping"
        ])
    }
    
    func testTappingLeft() throws {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(
            app,
            measureId: "finger-tapping",
            expectedImages: ["tap_left_1", "flat_surface"])
        next(app)
        handSelectionLeftOrRight(app, hand: "LEFT")
        next(app)
        next(app)
        conductTapping(app, nextButtonString: "Exit", duration: 40, expectedFiles: [
            "left_tapping.json",
            "left_tapping"
        ])
    }
    
    func testTappingRight() throws {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(
            app,
            measureId: "finger-tapping",
            expectedImages: ["tap_left_1", "flat_surface"])
        next(app)
        handSelectionLeftOrRight(app, hand: "RIGHT")
        next(app)
        next(app)
        conductTapping(app, nextButtonString: "Exit", duration: 40, expectedFiles: [
            "right_tapping.json",
            "right_tapping",
        ])
    }
    
    func testWalkThirtySecond() {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(
            app,
            measureId: "walk-thirty-second",
            expectedImages: ["walking_1", "smooth_surface", "pants_with_pockets", "walking_shoes"])
        next(app)
        next(app)
        next(app)
        next(app)
        conductMotion(app, nextButtonString: "Exit", duration: 40, expectedFiles: [
            "walk_motion.json"
        ])
    }
    
    func testWalkAndBalance() {
        let app = XCUIApplication()
        app.launch()
        
        navigatePastOverview(
            app,
            measureId: "walk-and-balance",
            expectedImages: ["walking_1", "smooth_surface", "pants_with_pockets", "walking_shoes"])
        next(app)
        next(app)
        next(app)
        next(app)
        conductMotion(app, nextButtonString: "Next", duration: 40)
        next(app)
        conductMotion(app, nextButtonString: "Exit", duration: 40, expectedFiles: [
            "walk_motion.json",
            "balance_motion.json"
        ])
    }
    
    /**
     Helper functions
     */
    
    func checkButtonsAndImagesExistsAndTap(_ app: XCUIApplication, _ elementName: String, _ expectedImages: [String] = []) {
        let button = app.buttons[elementName]
        XCTAssert(button.exists)
        
        /**
         In the case of an animation image this is meant to test only the first image of the animation, as well as the icons
         */
        expectedImages.forEach { imagename in
            XCTAssert(app.images[imagename].exists)
        }
        
        button.tap()
    }
    
    func navigatePastOverview(_ app: XCUIApplication, measureId: String, expectedImages: [String] = []) {
        checkButtonsAndImagesExistsAndTap(app, measureId)
        checkButtonsAndImagesExistsAndTap(app, "Get Started", expectedImages)
    }
    
    func handSelectionBoth(_ app: XCUIApplication) {
        checkButtonsAndImagesExistsAndTap(app, "Skip question")
    }
    
    func handSelectionLeftOrRight(_ app: XCUIApplication, hand handSelection: String) {
        let handSelectionPredicate = NSPredicate(format: "label CONTAINS '\(handSelection)'")
        let leftButton = app.switches.element(matching: handSelectionPredicate)
        XCTAssert(leftButton.exists)
        leftButton.tap()
        next(app)
    }
    
    func next(_ app: XCUIApplication, expectedImages: [String] = []) {
        checkButtonsAndImagesExistsAndTap(app, "Next", expectedImages)
    }
    
    func conductMotion(_ app: XCUIApplication, nextButtonString: String, duration: Double, expectedFiles: [String] = []) {
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
    
    func conductTapping(_ app: XCUIApplication, nextButtonString: String, duration: Double, expectedFiles: [String] = []) {
        let leftTapButton = app.staticTexts["LEFT_TAP"]
        let rightTapButton = app.staticTexts["RIGHT_TAP"]
        XCTAssert(leftTapButton.exists)
        XCTAssert(rightTapButton.exists)
        
        let buttons = [leftTapButton, rightTapButton]
        for ii in 0..<25 {
            buttons[ii % 2].tap()
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
