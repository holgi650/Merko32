//
//  ResultView.swift
//  Merko32
//

import SwiftUI

/// Auswertung (vorläufiger Platzhalter, wird in Schritt 8 ausgebaut).
struct ResultView: View {
    let result: GameResult
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Auswertung")
                .font(.largeTitle.bold())
            Text("\(result.correctCount) richtig · \(result.wrongCount) falsch · \(result.percent) %")
            Button("Neuer Durchlauf", action: onRestart)
                .buttonStyle(.borderedProminent)
        }
        .foregroundStyle(.white)
    }
}
