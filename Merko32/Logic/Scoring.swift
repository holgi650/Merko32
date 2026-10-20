//
//  Scoring.swift
//  Merko32
//

import Foundation

/// Ergebnis einer einzelnen Abfrage.
nonisolated enum QueryOutcome: Hashable, Sendable {
    case correct
    case wrong(input: String)
    /// Leer oder nur einstellig bei Zeitablauf – zählt als falsch.
    case incomplete(input: String)
    /// Bildschirm wurde wegen Abbruch nicht erreicht – zählt als falsch.
    case notReached

    var isCorrect: Bool { self == .correct }
}

/// Eine Zeile der Auswertung.
nonisolated struct QueryResult: Identifiable, Hashable, Sendable {
    let item: MemoryItem
    let screenIndex: Int
    let outcome: QueryOutcome

    var id: MemoryItem.ID { item.id }

    /// Anzeige der Eingabe in der Auswertungsliste.
    var displayInput: String {
        switch outcome {
        case .correct: String(item.number)
        case .wrong(let input): input
        case .incomplete: "–"
        case .notReached: "nicht erreicht"
        }
    }
}

/// Gesamtergebnis eines Durchlaufs.
nonisolated struct GameResult: Hashable, Sendable {
    /// Alle Abfragen in der Reihenfolge, in der sie gestellt wurden (bzw. worden wären).
    let entries: [QueryResult]

    var total: Int { entries.count }
    var correctCount: Int { entries.count(where: \.outcome.isCorrect) }
    var wrongCount: Int { total - correctCount }

    /// Prozent richtig bezogen auf alle Abfragen, kaufmännisch gerundet.
    var percent: Int {
        guard total > 0 else { return 0 }
        return Int((Double(correctCount) * 100 / Double(total)).rounded())
    }
}

/// Bewertet die Eingaben eines Durchlaufs.
nonisolated enum Scoring {

    /// - Parameters:
    ///   - answers: Feldinhalt pro Item (0–2 Ziffern).
    ///   - reachedScreenCount: Anzahl der erreichten Bildschirme; Abfragen auf späteren Bildschirmen gelten als „nicht erreicht“.
    static func evaluate(run: Run, answers: [MemoryItem.ID: String], reachedScreenCount: Int) -> GameResult {
        let entries = run.screens.flatMap { screen in
            screen.queries.map { item in
                QueryResult(
                    item: item,
                    screenIndex: screen.index,
                    outcome: outcome(for: item, input: answers[item.id] ?? "", reached: screen.index < reachedScreenCount)
                )
            }
        }
        return GameResult(entries: entries)
    }

    static func outcome(for item: MemoryItem, input: String, reached: Bool) -> QueryOutcome {
        guard reached else { return .notReached }
        guard input.count == 2, let number = Int(input) else { return .incomplete(input: input) }
        return number == item.number ? .correct : .wrong(input: input)
    }
}
