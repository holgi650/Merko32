//
//  NumberPadView.swift
//  Merko32
//

import SwiftUI

/// Eigener Ziffernblock `1–9, ⌫, 0, ⇥`, damit die Systemtastatur das Raster nie verdeckt.
struct NumberPadView: View {
    let isEnabled: Bool
    let onDigit: (Int) -> Void
    let onDelete: () -> Void
    let onNext: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(1...9, id: \.self) { digit in
                digitKey(digit)
            }
            key(systemImage: "delete.left", label: "Löschen", action: onDelete)
            digitKey(0)
            key(systemImage: "arrow.right.to.line", label: "Nächstes Feld", action: onNext)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.35)
    }

    private func digitKey(_ digit: Int) -> some View {
        Button {
            onDigit(digit)
        } label: {
            Text("\(digit)")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(PadKeyStyle())
    }

    private func key(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(PadKeyStyle())
        .accessibilityLabel(label)
    }
}

/// Taste mit leicht hellerem Hintergrund und Rückmeldung beim Drücken.
private struct PadKeyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(configuration.isPressed ? 0.30 : 0.12))
            )
    }
}

#Preview {
    NumberPadView(isEnabled: true, onDigit: { _ in }, onDelete: {}, onNext: {})
        .padding()
        .background(Color.appBackground)
}
