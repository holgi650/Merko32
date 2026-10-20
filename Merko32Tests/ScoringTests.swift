//
//  ScoringTests.swift
//  Merko32Tests
//

import Testing
@testable import Merko32

struct ScoringTests {

    let run: Run = {
        var rng = SeededGenerator(seed: 7)
        return RunGenerator.make(config: .standard, using: &rng)
    }()

    /// Richtige Antworten für alle Items.
    private var allCorrect: [MemoryItem.ID: String] {
        Dictionary(uniqueKeysWithValues: run.items.map { ($0.id, String($0.number)) })
    }

    /// Eine garantiert falsche zweistellige Zahl für das Item.
    private func wrongNumber(for item: MemoryItem) -> String {
        String(item.number == 99 ? 98 : item.number + 1)
    }

    @Test func allCorrectGivesHundredPercent() {
        let result = Scoring.evaluate(run: run, answers: allCorrect, reachedScreenCount: 16)
        #expect(result.total == 32)
        #expect(result.correctCount == 32)
        #expect(result.wrongCount == 0)
        #expect(result.percent == 100)
    }

    @Test func noAnswersGivesZeroPercent() {
        let result = Scoring.evaluate(run: run, answers: [:], reachedScreenCount: 16)
        #expect(result.correctCount == 0)
        #expect(result.wrongCount == 32)
        #expect(result.percent == 0)
        #expect(result.entries.allSatisfy { $0.outcome == .incomplete(input: "") && $0.displayInput == "–" })
    }

    @Test func entriesAreInQueryOrder() {
        let result = Scoring.evaluate(run: run, answers: [:], reachedScreenCount: 16)
        #expect(result.entries.map(\.item) == run.queriesInOrder)
        #expect(result.entries.map(\.screenIndex) == result.entries.map(\.screenIndex).sorted())
    }

    @Test func outcomeForSingleItem() {
        let item = MemoryItem(id: 0, combination: Combination(symbol: .star, color: .red), number: 42)
        #expect(Scoring.outcome(for: item, input: "42", reached: true) == .correct)
        #expect(Scoring.outcome(for: item, input: "24", reached: true) == .wrong(input: "24"))
        #expect(Scoring.outcome(for: item, input: "", reached: true) == .incomplete(input: ""))
        #expect(Scoring.outcome(for: item, input: "4", reached: true) == .incomplete(input: "4"))
        #expect(Scoring.outcome(for: item, input: "42", reached: false) == .notReached)
    }

    @Test func displayInputPerOutcome() {
        let item = MemoryItem(id: 0, combination: Combination(symbol: .star, color: .red), number: 42)
        func display(_ outcome: QueryOutcome) -> String {
            QueryResult(item: item, screenIndex: 1, outcome: outcome).displayInput
        }
        #expect(display(.correct) == "42")
        #expect(display(.wrong(input: "24")) == "24")
        #expect(display(.incomplete(input: "4")) == "–")
        #expect(display(.incomplete(input: "")) == "–")
        #expect(display(.notReached) == "nicht erreicht")
    }

    @Test func mixedAnswersAreCountedCorrectly() {
        let queries = run.queriesInOrder
        var answers = allCorrect
        answers[queries[0].id] = wrongNumber(for: queries[0])     // falsch
        answers[queries[1].id] = nil                              // leer
        answers[queries[2].id] = String(String(queries[2].number).prefix(1))  // einstellig

        let result = Scoring.evaluate(run: run, answers: answers, reachedScreenCount: 16)
        #expect(result.correctCount == 29)
        #expect(result.wrongCount == 3)
        #expect(result.percent == 91)  // 29/32 = 90,6 %
        #expect(result.entries[0].outcome == .wrong(input: wrongNumber(for: queries[0])))
        #expect(result.entries[1].outcome == .incomplete(input: ""))
        #expect(result.entries[2].outcome == .incomplete(input: String(String(queries[2].number).prefix(1))))
    }

    @Test func notReachedScreensCountAsWrong() {
        // Abbruch auf Bildschirm 5 (Index 4): Bildschirme 0–4 erreicht.
        let result = Scoring.evaluate(run: run, answers: allCorrect, reachedScreenCount: 5)
        let reachedQueries = run.screens.prefix(5).reduce(0) { $0 + $1.queries.count }  // 0+1+2+2+2 = 7

        #expect(reachedQueries == 7)
        #expect(result.total == 32)
        #expect(result.correctCount == 7)
        #expect(result.wrongCount == 25)
        #expect(result.percent == 22)  // 7/32 = 21,9 %
        #expect(result.entries.filter { $0.outcome == .notReached }.count == 25)
        #expect(result.entries.allSatisfy { ($0.screenIndex < 5) == ($0.outcome != .notReached) })
    }

    @Test func abortBeforeAnyQueryGivesZero() {
        let result = Scoring.evaluate(run: run, answers: [:], reachedScreenCount: 1)
        #expect(result.correctCount == 0)
        #expect(result.entries.allSatisfy { $0.outcome == .notReached })
    }
}
