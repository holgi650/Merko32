//
//  Combination.swift
//  Merko32
//

import Foundation

/// Symbol in einer Farbe – das, was sich der Spieler zusammen mit einer Zahl merkt.
nonisolated struct Combination: Hashable, Sendable {
    let symbol: GameSymbol
    let color: GameColor

    /// VoiceOver-Label, z. B. „roter Stern“ oder „gelbes Herz“.
    var accessibilityLabel: String {
        "\(color.adjective(for: symbol.gender)) \(symbol.germanName)"
    }
}
