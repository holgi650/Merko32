//
//  GameSymbol.swift
//  Merko32
//

import Foundation

/// Grammatisches Geschlecht des deutschen Symbolnamens (für VoiceOver-Labels wie „roter Stern“).
nonisolated enum GrammaticalGender: Sendable {
    case masculine, feminine, neuter
}

/// Ein Symbol des Spiels: SF-Symbol-Name plus deutscher Name.
nonisolated struct GameSymbol: Hashable, Sendable {
    let systemName: String
    let germanName: String
    let gender: GrammaticalGender
}

nonisolated extension GameSymbol {
    static let star = GameSymbol(systemName: "star.fill", germanName: "Stern", gender: .masculine)
    static let heart = GameSymbol(systemName: "heart.fill", germanName: "Herz", gender: .neuter)
    static let triangle = GameSymbol(systemName: "triangle.fill", germanName: "Dreieck", gender: .neuter)
    static let square = GameSymbol(systemName: "square.fill", germanName: "Quadrat", gender: .neuter)
    static let moon = GameSymbol(systemName: "moon.fill", germanName: "Mond", gender: .masculine)
    static let bolt = GameSymbol(systemName: "bolt.fill", germanName: "Blitz", gender: .masculine)
}
