//
//  FieldView.swift
//  Merko32
//

import SwiftUI

/// Ein Feld des 2×2-Rasters: Zeigefeld (Symbol + Zahl) oder Abfragefeld (Symbol + Eingabekästchen).
struct FieldView: View {
    let field: Field
    let input: String
    let isFocused: Bool

    private var combination: Combination { field.item.combination }

    var body: some View {
        VStack(spacing: 8) {
            SymbolView(combination: combination, size: 48)
                .frame(height: 56)

            switch field {
            case .show(let item):
                Text("\(item.number)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            case .query:
                inputBox
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(field.isQuery ? 0.10 : 0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white, lineWidth: isFocused ? 4 : 0)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(field.isQuery ? .isButton : [])
        .accessibilityAddTraits(isFocused ? .isSelected : [])
        .accessibilityHint(field.isQuery && !isFocused ? "Doppeltippen, um dieses Feld auszuwählen" : "")
    }

    /// Zwei Ziffernplätze; leere Plätze bleiben als Rahmen sichtbar.
    private var inputBox: some View {
        HStack(spacing: 6) {
            ForEach(0..<2, id: \.self) { index in
                let characters = Array(input)
                Text(index < characters.count ? String(characters[index]) : " ")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.white.opacity(0.6), lineWidth: 2)
                    )
            }
        }
    }

    private var accessibilityText: String {
        switch field {
        case .show(let item):
            "\(combination.accessibilityLabel), \(item.number)"
        case .query:
            input.isEmpty
                ? "\(combination.accessibilityLabel), Zahl eingeben"
                : "\(combination.accessibilityLabel), Eingabe \(input)"
        }
    }
}

#Preview {
    let star = MemoryItem(id: 0, combination: Combination(symbol: .star, color: .red), number: 42)
    let moon = MemoryItem(id: 1, combination: Combination(symbol: .moon, color: .blue), number: 17)
    HStack(spacing: 12) {
        FieldView(field: .show(star), input: "", isFocused: false)
        FieldView(field: .query(moon), input: "1", isFocused: true)
    }
    .frame(height: 200)
    .padding()
    .background(Color.appBackground)
}
