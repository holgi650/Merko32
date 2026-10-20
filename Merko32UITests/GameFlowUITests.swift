//
//  GameFlowUITests.swift
//  Merko32UITests
//

import XCTest

/// Spielt den Ablauf Start → Spiel → Abbruch → Auswertung → Neuer Durchlauf mit der 3-Sekunden-Config durch.
final class GameFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-debugTimes"]
        app.launch()
        return app
    }

    @MainActor
    private func snapshot(_ name: String, of app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testStartAbortAndRestart() throws {
        let app = launchApp()
        snapshot("1-start", of: app)
        app.buttons["Start"].tap()

        XCTAssertTrue(app.staticTexts["Bildschirm 1/16"].waitForExistence(timeout: 2))
        snapshot("2-spiel", of: app)

        // Nach Ablauf von 3 s folgt Bildschirm 2.
        XCTAssertTrue(app.staticTexts["Bildschirm 2/16"].waitForExistence(timeout: 5))

        app.buttons["Abbrechen"].tap()
        XCTAssertTrue(app.staticTexts["Auswertung"].waitForExistence(timeout: 2))
        snapshot("3-auswertung", of: app)

        app.buttons["Neuer Durchlauf"].tap()
        XCTAssertTrue(app.staticTexts["Bildschirm 1/16"].waitForExistence(timeout: 2))
    }
}
