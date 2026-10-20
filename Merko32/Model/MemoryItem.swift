//
//  MemoryItem.swift
//  Merko32
//

import Foundation

/// Eine zu merkende Kombination mit ihrer Zahl. Die `id` ist die Position in der Zeige-Reihenfolge.
nonisolated struct MemoryItem: Identifiable, Hashable, Sendable {
    let id: Int
    let combination: Combination
    let number: Int
}
