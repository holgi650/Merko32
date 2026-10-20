//
//  CountdownView.swift
//  Merko32
//

import SwiftUI

/// Restzeit als Zahl und als Balken.
struct CountdownView: View {
    let remainingSeconds: Int
    let totalSeconds: Int

    private var fraction: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(remainingSeconds) / Double(totalSeconds)
    }

    /// In den letzten Sekunden wird der Countdown rot.
    private var tint: Color {
        remainingSeconds <= 5 ? Color(GameColor.red) : .white
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(remainingSeconds) s")
                .font(.title2.bold())
                .monospacedDigit()
                .foregroundStyle(tint)
                .frame(minWidth: 56, alignment: .leading)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.15))
                    Capsule()
                        .fill(tint)
                        .frame(width: proxy.size.width * fraction)
                        .animation(.linear(duration: 1), value: remainingSeconds)
                }
            }
            .frame(height: 10)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Restzeit")
        .accessibilityValue("\(remainingSeconds) Sekunden")
    }
}

#Preview {
    VStack(spacing: 24) {
        CountdownView(remainingSeconds: 21, totalSeconds: 30)
        CountdownView(remainingSeconds: 4, totalSeconds: 30)
    }
    .padding()
    .background(Color.appBackground)
}
