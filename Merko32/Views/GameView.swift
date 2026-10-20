//
//  GameView.swift
//  Merko32
//

import SwiftUI

/// Spielbildschirm (vorläufiger Platzhalter, wird in Schritt 6 ausgebaut).
struct GameView: View {
    let session: GameSession

    var body: some View {
        VStack(spacing: 16) {
            Text("Bildschirm \(session.screenIndex + 1)/\(session.config.screenCount)")
                .font(.headline)
            Text("\(session.remainingSeconds)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()
            Button("Abbrechen", role: .destructive) {
                session.abort()
            }
        }
        .foregroundStyle(.white)
    }
}
