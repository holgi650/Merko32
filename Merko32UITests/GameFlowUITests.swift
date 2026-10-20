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

    /// Auf Bildschirm 2 (eine Abfrage) zwei Ziffern tippen, eine löschen und neu tippen.
    @MainActor
    func testNumberPadFillsFocusedQuery() throws {
        let app = launchApp()
        app.buttons["Start"].tap()
        XCTAssertTrue(app.staticTexts["Bildschirm 2/16"].waitForExistence(timeout: 5))

        app.buttons["4"].tap()
        app.buttons["0"].tap()
        app.buttons["Löschen"].tap()
        app.buttons["2"].tap()

        let field = app.descendants(matching: .any).matching(NSPredicate(format: "label ENDSWITH %@", "Eingabe 42")).firstMatch
        XCTAssertTrue(field.exists)
        snapshot("eingabe", of: app)
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

        // Abbruch erst nach Bestätigung; „Weiterspielen“ bleibt im Spiel.
        app.buttons["Abbrechen"].tap()
        XCTAssertTrue(app.alerts["Wirklich abbrechen?"].waitForExistence(timeout: 2))
        snapshot("3-abbruch-dialog", of: app)
        app.alerts.buttons["Weiterspielen"].tap()
        XCTAssertTrue(app.staticTexts["Bildschirm 3/16"].waitForExistence(timeout: 5))
        snapshot("4-bildschirm-3", of: app)

        app.buttons["Abbrechen"].tap()
        app.alerts.buttons["Ja, abbrechen"].tap()
        XCTAssertTrue(app.staticTexts["Auswertung"].waitForExistence(timeout: 2))
        snapshot("5-auswertung", of: app)

        app.buttons["Neuer Durchlauf"].tap()
        XCTAssertTrue(app.staticTexts["Bildschirm 1/16"].waitForExistence(timeout: 2))
    }
}
