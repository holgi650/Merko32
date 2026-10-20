//
//  Color+Hex.swift
//  Merko32
//

import SwiftUI

extension Color {
    /// Farbe aus einem Hex-Wert 0xRRGGBB.
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    init(_ gameColor: GameColor) {
        self.init(hex: gameColor.hex)
    }

    static let appBackground = Color(GameColor.background)
}
