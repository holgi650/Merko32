//
//  GameColor.swift
//  Merko32
//

import Foundation

/// Eine Spielfarbe als Hex-Wert (0xRRGGBB) plus deutscher Name. Bewusst ohne SwiftUI.
nonisolated struct GameColor: Hashable, Sendable {
    let hex: UInt32
    let germanName: String
    /// Adjektivstamm ohne Endung, z. B. „rot“ → „roter“, „rotes“.
    let adjectiveStem: String

    func adjective(for gender: GrammaticalGender) -> String {
        switch gender {
        case .masculine: adjectiveStem + "er"
        case .feminine: adjectiveStem + "e"
        case .neuter: adjectiveStem + "es"
        }
    }
}

nonisolated extension GameColor {
    static let red = GameColor(hex: 0xE53935, germanName: "Rot", adjectiveStem: "rot")
    static let yellow = GameColor(hex: 0xFDD835, germanName: "Gelb", adjectiveStem: "gelb")
    static let green = GameColor(hex: 0x43A047, germanName: "Grün", adjectiveStem: "grün")
    static let blue = GameColor(hex: 0x1E57D6, germanName: "Blau", adjectiveStem: "blau")
    static let orange = GameColor(hex: 0xFB8C00, germanName: "Orange", adjectiveStem: "orangefarben")
    static let violet = GameColor(hex: 0x8E24AA, germanName: "Violett", adjectiveStem: "violett")

    /// Hintergrund der App (Dunkelgrau).
    static let background = GameColor(hex: 0x2B2B2B, germanName: "Dunkelgrau", adjectiveStem: "dunkelgrau")
}
