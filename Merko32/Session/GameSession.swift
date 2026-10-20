//
//  GameSession.swift
//  Merko32
//

import Foundation
import Observation

/// Ablaufsteuerung eines Durchlaufs. Kennt keine echte Zeit – der Ticker ruft `tick()` auf.
@Observable
@MainActor
final class GameSession {

    enum Phase: Equatable {
        case start
        case playing
        case result(GameResult)
    }

    private(set) var phase: Phase = .start
    private(set) var run: Run?
    private(set) var screenIndex = 0
    private(set) var remainingSeconds = 0
    /// Feldinhalt (0–2 Ziffern) pro abgefragtem Item.
    private(set) var answers: [MemoryItem.ID: String] = [:]
    private(set) var focusedItemID: MemoryItem.ID?

    let config: GameConfig
    @ObservationIgnored private let ticker: any Ticker
    @ObservationIgnored private let makeRun: (GameConfig) -> Run

    init(
        config: GameConfig = .standard,
        ticker: any Ticker = ClockTicker(),
        makeRun: @escaping (GameConfig) -> Run = { RunGenerator.make(config: $0) }
    ) {
        self.config = config
        self.ticker = ticker
        self.makeRun = makeRun
    }

    // MARK: - Abgeleitete Werte

    var currentScreen: Screen? {
        guard phase == .playing, let run else { return nil }
        return run.screens[screenIndex]
    }

    /// Abfragen des aktuellen Bildschirms in Feldreihenfolge.
    private var currentQueryIDs: [MemoryItem.ID] {
        currentScreen?.queries.map(\.id) ?? []
    }

    func answer(for id: MemoryItem.ID) -> String {
        answers[id] ?? ""
    }

    // MARK: - Ablauf

    /// Startet einen neuen Durchlauf (vom Start- oder Auswertungsbildschirm aus).
    func start() {
        let run = makeRun(config)
        self.run = run
        answers = [:]
        phase = .playing
        enterScreen(0)
        ticker.start { [weak self] in
            self?.tick()
        }
    }

    /// Zählt eine Sekunde herunter; bei 0 folgt der nächste Bildschirm bzw. die Auswertung.
    func tick() {
        guard phase == .playing, let run else { return }
        remainingSeconds -= 1
        guard remainingSeconds <= 0 else { return }

        if screenIndex + 1 < run.screens.count {
            enterScreen(screenIndex + 1)
        } else {
            finish(reachedScreenCount: run.screens.count)
        }
    }

    /// Bricht ab und geht direkt zur Auswertung.
    func abort() {
        guard phase == .playing else { return }
        finish(reachedScreenCount: screenIndex + 1)
    }

    private func enterScreen(_ index: Int) {
        guard let run else { return }
        screenIndex = index
        remainingSeconds = run.screens[index].seconds
        focusedItemID = currentQueryIDs.first
    }

    private func finish(reachedScreenCount: Int) {
        ticker.stop()
        focusedItemID = nil
        guard let run else { return }
        phase = .result(Scoring.evaluate(run: run, answers: answers, reachedScreenCount: reachedScreenCount))
    }

    // MARK: - Eingabe

    func input(digit: Int) {
        guard phase == .playing, let id = focusedItemID, (0...9).contains(digit) else { return }
        var text = answer(for: id)
        guard text.count < 2 else { return }
        guard !(text.isEmpty && digit == 0) else { return }  // keine führende 0

        text.append(String(digit))
        answers[id] = text

        if text.count == 2 {
            focusNextEmpty(after: id)
        }
    }

    func deleteDigit() {
        guard phase == .playing, let id = focusedItemID else { return }
        var text = answer(for: id)
        guard !text.isEmpty else { return }
        text.removeLast()
        answers[id] = text
    }

    /// Springt zyklisch zur nächsten Abfrage des Bildschirms.
    func focusNext() {
        let ids = currentQueryIDs
        guard let id = focusedItemID, let index = ids.firstIndex(of: id) else {
            focusedItemID = ids.first
            return
        }
        focusedItemID = ids[(index + 1) % ids.count]
    }

    func focus(id: MemoryItem.ID) {
        guard currentQueryIDs.contains(id) else { return }
        focusedItemID = id
    }

    /// Nächste leere Abfrage nach `id` (zyklisch); gibt es keine, bleibt der Fokus stehen.
    private func focusNextEmpty(after id: MemoryItem.ID) {
        let ids = currentQueryIDs
        guard let index = ids.firstIndex(of: id) else { return }
        for offset in 1..<max(ids.count, 1) {
            let candidate = ids[(index + offset) % ids.count]
            if answer(for: candidate).isEmpty {
                focusedItemID = candidate
                return
            }
        }
    }
}
