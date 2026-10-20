//
//  Screen.swift
//  Merko32
//

import Foundation

/// Ein Feld auf einem Bildschirm: entweder eine neue Kombination zeigen oder sie abfragen.
nonisolated enum Field: Hashable, Sendable {
    case show(MemoryItem)
    case query(MemoryItem)

    var item: MemoryItem {
        switch self {
        case .show(let item), .query(let item): item
        }
    }

    var isQuery: Bool {
        if case .query = self { true } else { false }
    }
}

/// Ein Bildschirm des Durchlaufs mit seinem Zeitlimit und seinen Feldern.
nonisolated struct Screen: Hashable, Sendable {
    let index: Int
    let seconds: Int
    let fields: [Field]

    var queries: [MemoryItem] {
        fields.filter(\.isQuery).map(\.item)
    }
}
