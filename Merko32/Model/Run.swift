//
//  Run.swift
//  Merko32
//

import Foundation

/// Ein kompletter Durchlauf: alle Items in Zeige-Reihenfolge und alle Bildschirme.
nonisolated struct Run: Hashable, Sendable {
    let items: [MemoryItem]
    let screens: [Screen]

    /// Alle Abfragen in der Reihenfolge, in der sie gestellt werden.
    var queriesInOrder: [MemoryItem] {
        screens.flatMap(\.queries)
    }
}
