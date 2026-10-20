//
//  SymbolView.swift
//  Merko32
//

import SwiftUI

/// Symbol in seiner Farbe mit dezentem hellem Rand.
/// Der Rand sorgt dafür, dass auch Blau und Violett auf `#2B2B2B` genug Kontrast haben (sonst nur ca. 2 : 1).
struct SymbolView: View {
    let combination: Combination
    let size: CGFloat

    private var outlineWidth: CGFloat { max(1, size / 40) }

    private let outlineOffsets: [CGSize] = [
        CGSize(width: -1, height: 0), CGSize(width: 1, height: 0),
        CGSize(width: 0, height: -1), CGSize(width: 0, height: 1),
        CGSize(width: -0.7, height: -0.7), CGSize(width: 0.7, height: -0.7),
        CGSize(width: -0.7, height: 0.7), CGSize(width: 0.7, height: 0.7),
    ]

    var body: some View {
        ZStack {
            ForEach(outlineOffsets.indices, id: \.self) { index in
                symbol
                    .foregroundStyle(.white.opacity(0.55))
                    .offset(x: outlineOffsets[index].width * outlineWidth, y: outlineOffsets[index].height * outlineWidth)
            }
            symbol
                .foregroundStyle(Color(combination.color))
        }
        .accessibilityHidden(true)
    }

    private var symbol: some View {
        Image(systemName: combination.symbol.systemName)
            .font(.system(size: size, weight: .semibold))
    }
}

#Preview {
    let colors: [GameColor] = [.red, .yellow, .green, .blue, .orange, .violet]
    HStack {
        ForEach(colors, id: \.self) { color in
            SymbolView(combination: Combination(symbol: .star, color: color), size: 44)
        }
    }
    .padding()
    .background(Color.appBackground)
}
