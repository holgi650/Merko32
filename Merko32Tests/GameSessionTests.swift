//
//  GameSessionTests.swift
//  Merko32Tests
//

import Testing
@testable import Merko32

@MainActor
struct GameSessionTests {

    let ticker = ManualTicker()
    let session: GameSession

    init() {
        session = GameSession(config: .standard, ticker: ticker) { config in
            var rng = SeededGenerator(seed: 3)
            return RunGenerator.make(config: config, using: &rng)
        }
    }

    /// Summe aller Bildschirmzeiten: 2 × (30+27+24+21+18+15+12+10) = 314.
    private var totalSeconds: Int { GameConfig.standard.secondsPerScreen.reduce(0, +) }

    /// Tickt bis zum Beginn des Bildschirms mit dem Index `index`.
    private func advance(toScreen index: Int) {
        ticker.fire(times: GameConfig.standard.secondsPerScreen.prefix(index).reduce(0, +))
    }

    private func result() -> GameResult? {
        if case .result(let result) = session.phase { result } else { nil }
    }

    private func queryIDs() -> [MemoryItem.ID] {
        session.currentScreen?.queries.map(\.id) ?? []
    }

    // MARK: - Ablauf

    @Test func startsInStartPhase() {
        #expect(session.phase == .start)
        #expect(session.currentScreen == nil)
        #expect(!ticker.isRunning)
    }

    @Test func startBeginsFirstScreenAndTicker() {
        session.start()
        #expect(session.phase == .playing)
        #expect(session.screenIndex == 0)
        #expect(session.remainingSeconds == 30)
        #expect(ticker.isRunning)
    }

    @Test func tickCountsDown() {
        session.start()
        ticker.fire(times: 5)
        #expect(session.remainingSeconds == 25)
        #expect(session.screenIndex == 0)
    }

    @Test func after30TicksSecondScreenIsActive() {
        session.start()
        ticker.fire(times: 29)
        #expect(session.screenIndex == 0)
        ticker.fire()
        #expect(session.screenIndex == 1)
        #expect(session.remainingSeconds == 30)
    }

    @Test func screensFollowConfiguredTimes() {
        session.start()
        for (index, seconds) in GameConfig.standard.secondsPerScreen.enumerated() {
            #expect(session.screenIndex == index)
            #expect(session.remainingSeconds == seconds)
            ticker.fire(times: seconds)
        }
        #expect(result() != nil)
    }

    @Test func afterAllTicksPhaseIsResult() {
        #expect(totalSeconds == 314)
        session.start()
        ticker.fire(times: totalSeconds - 1)
        #expect(session.phase == .playing)
        #expect(session.screenIndex == 15)
        ticker.fire()
        #expect(result()?.total == 32)
        #expect(!ticker.isRunning)
    }

    @Test func ticksAfterResultChangeNothing() {
        session.start()
        ticker.fire(times: totalSeconds)
        let phase = session.phase
        session.tick()
        #expect(session.phase == phase)
    }

    @Test func abortGoesDirectlyToResultAndStopsTicker() throws {
        session.start()
        advance(toScreen: 4)
        session.abort()

        let result = try #require(result())
        #expect(!ticker.isRunning)
        #expect(ticker.stopCount >= 1)
        // Bildschirme 0–4 erreicht → 7 Abfragen gewertet, 25 nicht erreicht.
        #expect(result.entries.filter { $0.outcome == .notReached }.count == 25)
        #expect(result.correctCount == 0)
    }

    @Test func newRunAfterResultStartsFresh() {
        session.start()
        advance(toScreen: 1)
        session.input(digit: 5)
        session.abort()

        session.start()
        #expect(session.phase == .playing)
        #expect(session.screenIndex == 0)
        #expect(session.answers.isEmpty)
        #expect(ticker.isRunning)
        #expect(ticker.startCount == 2)
    }

    // MARK: - Eingaben

    @Test func answersArePreservedAndScored() throws {
        session.start()
        let run = try #require(session.run)

        // Auf jedem Bildschirm alle Abfragen richtig beantworten.
        for screen in run.screens {
            for item in screen.queries {
                session.focus(id: item.id)
                String(item.number).forEach { session.input(digit: $0.wholeNumberValue!) }
            }
            ticker.fire(times: screen.seconds)
        }

        let result = try #require(result())
        #expect(result.correctCount == 32)
        #expect(result.percent == 100)
    }

    @Test func answersSurviveScreenChange() throws {
        session.start()
        advance(toScreen: 1)
        let id = try #require(queryIDs().first)
        session.input(digit: 4)
        session.input(digit: 2)
        ticker.fire(times: 30)
        #expect(session.screenIndex == 2)
        #expect(session.answer(for: id) == "42")
    }

    @Test func leadingZeroIsRejected() {
        session.start()
        advance(toScreen: 1)
        let id = queryIDs()[0]
        session.input(digit: 0)
        #expect(session.answer(for: id) == "")
        session.input(digit: 1)
        session.input(digit: 0)
        #expect(session.answer(for: id) == "10")
    }

    @Test func atMostTwoDigits() {
        session.start()
        advance(toScreen: 1)  // nur eine Abfrage → Fokus bleibt nach 2 Ziffern stehen
        let id = queryIDs()[0]
        session.input(digit: 1)
        session.input(digit: 2)
        session.input(digit: 3)
        #expect(session.focusedItemID == id)
        #expect(session.answer(for: id) == "12")
    }

    @Test func deleteRemovesLastDigit() {
        session.start()
        advance(toScreen: 1)
        let id = queryIDs()[0]
        session.input(digit: 7)
        session.input(digit: 8)
        session.deleteDigit()
        #expect(session.answer(for: id) == "7")
        session.deleteDigit()
        session.deleteDigit()
        #expect(session.answer(for: id) == "")
    }

    @Test func inputWithoutFocusIsIgnored() {
        session.start()  // Bildschirm 1 hat keine Abfragen
        #expect(session.focusedItemID == nil)
        session.input(digit: 5)
        #expect(session.answers.isEmpty)
    }

    // MARK: - Fokus

    @Test func focusStartsOnFirstQueryOfEachScreen() {
        session.start()
        for index in 1..<16 {
            ticker.fire(times: session.remainingSeconds)
            #expect(session.screenIndex == index)
            #expect(session.focusedItemID == queryIDs().first)
        }
    }

    @Test func secondDigitMovesFocusToNextEmptyQuery() {
        session.start()
        advance(toScreen: 15)  // 4 Abfragen
        let ids = queryIDs()
        #expect(ids.count == 4)

        // Zweite Abfrage schon ausfüllen, dann bei der ersten tippen → springt zur dritten.
        session.focus(id: ids[1])
        session.input(digit: 1); session.input(digit: 1)
        #expect(session.focusedItemID == ids[2])

        session.focus(id: ids[0])
        session.input(digit: 2); session.input(digit: 2)
        #expect(session.focusedItemID == ids[2])
    }

    @Test func autoFocusWrapsAroundAndStopsWhenAllFilled() {
        session.start()
        advance(toScreen: 15)
        let ids = queryIDs()

        session.focus(id: ids[3])
        session.input(digit: 3); session.input(digit: 3)
        #expect(session.focusedItemID == ids[0])  // zyklisch

        for id in ids.prefix(3) {
            #expect(session.focusedItemID == id)
            session.input(digit: 4); session.input(digit: 4)
        }
        // Alles ausgefüllt → Fokus bleibt auf dem zuletzt ausgefüllten Feld.
        #expect(session.focusedItemID == ids[2])
    }

    @Test func focusNextCyclesThroughQueries() {
        session.start()
        advance(toScreen: 14)  // 3 Abfragen
        let ids = queryIDs()
        #expect(ids.count == 3)
        #expect(session.focusedItemID == ids[0])
        session.focusNext(); #expect(session.focusedItemID == ids[1])
        session.focusNext(); #expect(session.focusedItemID == ids[2])
        session.focusNext(); #expect(session.focusedItemID == ids[0])
    }

    @Test func focusOnShowFieldIsIgnored() throws {
        session.start()
        advance(toScreen: 2)
        let screen = try #require(session.currentScreen)
        let showID = try #require(screen.fields.first { !$0.isQuery }?.item.id)
        let before = session.focusedItemID
        session.focus(id: showID)
        #expect(session.focusedItemID == before)
    }
}

/// Prüft den echten Ticker mit einer kurzen Wartezeit.
@MainActor
struct ClockTickerTests {

    @Test func clockTickerTicksAndStops() async throws {
        let ticker = ClockTicker()
        var ticks = 0
        ticker.start { ticks += 1 }
        try await Task.sleep(for: .milliseconds(2300))
        ticker.stop()
        let ticksAtStop = ticks
        #expect((1...3).contains(ticksAtStop))
        try await Task.sleep(for: .milliseconds(1300))
        #expect(ticks == ticksAtStop)
    }
}
