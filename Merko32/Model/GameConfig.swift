//
//  GameConfig.swift
//  Merko32
//

import Foundation

/// Alle Spielparameter an einer Stelle.
nonisolated struct GameConfig: Sendable {
    var symbols: [GameSymbol]
    var colors: [GameColor]
    var combinationsPerRun: Int
    var numberRange: ClosedRange<Int>
    var fieldsPerScreen: Int
    var newPerScreen: [Int]
    var queryPerScreen: [Int]
    var secondsPerScreen: [Int]

    var screenCount: Int { secondsPerScreen.count }

    static let standard = GameConfig(
        symbols: [.star, .heart, .triangle, .square, .moon, .bolt],
        colors: [.red, .yellow, .green, .blue, .orange, .violet],
        combinationsPerRun: 32,
        numberRange: 11...99,
        fieldsPerScreen: 4,
        newPerScreen: [4, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 0],
        queryPerScreen: [0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 4],
        secondsPerScreen: [30, 30, 27, 27, 24, 24, 21, 21, 18, 18, 15, 15, 12, 12, 10, 10]
    )

    #if DEBUG
    /// Für schnelle manuelle Tests: wie `standard`, aber 3 Sekunden pro Bildschirm.
    static let debug: GameConfig = {
        var config = GameConfig.standard
        config.secondsPerScreen = Array(repeating: 3, count: config.screenCount)
        return config
    }()
    #endif
}

// MARK: - Prüfung

nonisolated extension GameConfig {
    enum ValidationError: Equatable, Sendable {
        case duplicateSymbols
        case duplicateColors
        case notEnoughCombinations(available: Int, required: Int)
        case numberRangeTooSmall(available: Int, required: Int)
        case noScreens
        case arrayLengthMismatch
        case fieldCountMismatch(screen: Int)
        case nonPositiveSeconds(screen: Int)
        case newSumMismatch(sum: Int)
        case querySumMismatch(sum: Int)
        /// Vor diesem Bildschirm gibt es nicht genug gezeigte, noch nicht abgefragte Items.
        case notEnoughItemsToQuery(screen: Int)
    }

    /// Liefert alle Regelverstöße; leer bedeutet gültig.
    func validate() -> [ValidationError] {
        var errors: [ValidationError] = []

        if Set(symbols).count != symbols.count { errors.append(.duplicateSymbols) }
        if Set(colors).count != colors.count { errors.append(.duplicateColors) }

        let available = symbols.count * colors.count
        if available < combinationsPerRun {
            errors.append(.notEnoughCombinations(available: available, required: combinationsPerRun))
        }
        if numberRange.count < combinationsPerRun {
            errors.append(.numberRangeTooSmall(available: numberRange.count, required: combinationsPerRun))
        }

        guard screenCount > 0 else {
            errors.append(.noScreens)
            return errors
        }
        guard newPerScreen.count == screenCount, queryPerScreen.count == screenCount else {
            errors.append(.arrayLengthMismatch)
            return errors
        }

        for screen in 0..<screenCount {
            if newPerScreen[screen] + queryPerScreen[screen] != fieldsPerScreen {
                errors.append(.fieldCountMismatch(screen: screen))
            }
            if secondsPerScreen[screen] <= 0 {
                errors.append(.nonPositiveSeconds(screen: screen))
            }
        }

        let newSum = newPerScreen.reduce(0, +)
        let querySum = queryPerScreen.reduce(0, +)
        if newSum != combinationsPerRun { errors.append(.newSumMismatch(sum: newSum)) }
        if querySum != combinationsPerRun { errors.append(.querySumMismatch(sum: querySum)) }

        // Präfixbedingung: gezeigt(< s) − abgefragt(< s) ≥ queryPerScreen[s]
        var shown = 0
        var queried = 0
        for screen in 0..<screenCount {
            if shown - queried < queryPerScreen[screen] {
                errors.append(.notEnoughItemsToQuery(screen: screen))
            }
            shown += newPerScreen[screen]
            queried += queryPerScreen[screen]
        }

        return errors
    }

    /// Bricht ab, wenn die Config ungültig ist.
    func preconditionValid() {
        let errors = validate()
        precondition(errors.isEmpty, "Ungültige GameConfig: \(errors)")
    }
}
