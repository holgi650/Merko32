//
//  RunGenerator.swift
//  Merko32
//

import Foundation

/// Erzeugt einen zufälligen Durchlauf. Reine Funktion: Der Zufall kommt nur aus dem übergebenen Generator.
nonisolated enum RunGenerator {

    static func make(config: GameConfig, using rng: inout some RandomNumberGenerator) -> Run {
        config.preconditionValid()
        let count = config.combinationsPerRun

        // 1. Alle Kombinationen bilden, mischen, die ersten 32 nehmen.
        let allCombinations = config.symbols.flatMap { symbol in
            config.colors.map { Combination(symbol: symbol, color: $0) }
        }
        let combinations = allCombinations.shuffled(using: &rng).prefix(count)

        // 2. Zahlen ohne Zurücklegen ziehen.
        let numbers = Array(config.numberRange).shuffled(using: &rng).prefix(count)

        // 3. Zusammenführen – in dieser Reihenfolge werden die Items gezeigt.
        let items = zip(combinations, numbers).enumerated().map { index, pair in
            MemoryItem(id: index, combination: pair.0, number: pair.1)
        }

        // 4. Bildschirme aufbauen. Der Pool enthält gezeigte, noch nicht abgefragte Items.
        var pool: [MemoryItem] = []
        var next = 0
        var screens: [Screen] = []

        for screen in 0..<config.screenCount {
            // Abfragen zuerst ziehen, damit nur Items früherer Bildschirme abgefragt werden.
            var queries: [MemoryItem] = []
            for _ in 0..<config.queryPerScreen[screen] {
                let index = Int.random(in: pool.indices, using: &rng)
                queries.append(pool.remove(at: index))
            }

            let news = items[next ..< next + config.newPerScreen[screen]]
            next += news.count
            // Erst jetzt kommen die neuen Items in den Pool.
            pool.append(contentsOf: news)

            let fields = (news.map(Field.show) + queries.map(Field.query)).shuffled(using: &rng)
            screens.append(Screen(index: screen, seconds: config.secondsPerScreen[screen], fields: fields))
        }

        assert(pool.isEmpty, "Nach dem letzten Bildschirm dürfen keine unabgefragten Items übrig sein")
        assert(next == items.count)

        return Run(items: items, screens: screens)
    }

    /// Bequemer Einstieg für die App mit dem System-Zufallsgenerator.
    static func make(config: GameConfig) -> Run {
        var rng = SystemRandomNumberGenerator()
        return make(config: config, using: &rng)
    }
}
