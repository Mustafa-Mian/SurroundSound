//
//  SurroundSoundUITests.swift
//  SurroundSoundUITests
//
//  Created by Mustafa Mian on 2026-08-27.
//

import XCTest

final class SurroundSoundUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws { }

    // Helper to launch and dismiss the welcome overlay if present
    @discardableResult
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        // Dismiss the welcome screen overlay if it appears
        let welcome = app.otherElements["Welcome to SurroundSound"]
        if welcome.waitForExistence(timeout: 2) {
            welcome.tap()
        } else {
            // Fallback: tap anywhere to proceed
            app.tap()
        }
        return app
    }

    @MainActor
    func testStartButtonAndToolbarPresence() throws {
        let app = launchApp()
        // Verify primary control button exists
        XCTAssertTrue(app.buttons["Start a Session"].waitForExistence(timeout: 2))
        // Verify toolbar items with accessibility labels exist
        XCTAssertTrue(app.buttons["View history"].exists)
        XCTAssertTrue(app.buttons["View help"].exists)
    }

    @MainActor
    func testNavigateToHelpAndBack() throws {
        let app = launchApp()
        app.buttons["View help"].tap()
        // Verify Help screen
        let helpNav = app.navigationBars["Help"]
        XCTAssertTrue(helpNav.waitForExistence(timeout: 3))
        // Go back
        helpNav.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["Start a Session"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testNavigateToHistoryAndBack() throws {
        let app = launchApp()
        app.buttons["View history"].tap()
        // Verify History screen
        let historyNav = app.navigationBars["History"]
        XCTAssertTrue(historyNav.waitForExistence(timeout: 3))
        // Go back
        historyNav.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["Start a Session"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launch()
        }
    }
}
