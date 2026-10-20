//
//  ContentView.swift
//  Merko32
//
//  Created by Holger Jass on 20.10.26.
//

import SwiftUI

/// RootView: schaltet je nach Phase der Session zwischen Start, Spiel und Auswertung um.
struct ContentView: View {
    @State private var session = GameSession(config: Self.config)

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            switch session.phase {
            case .start:
                StartView(onStart: session.start)
            case .playing:
                GameView(session: session)
            case .result(let result):
                ResultView(result: result, onRestart: session.start)
            }
        }
        .preferredColorScheme(.dark)
        .sensoryFeedback(.success, trigger: isShowingResult) { _, isResult in isResult }
    }

    private var isShowingResult: Bool {
        if case .result = session.phase { true } else { false }
    }

    /// In DEBUG-Builds lässt sich mit dem Startargument `-debugTimes` die 3-Sekunden-Config wählen.
    private static var config: GameConfig {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-debugTimes") {
            return .debug
        }
        #endif
        return .standard
    }
}

#Preview {
    ContentView()
}
