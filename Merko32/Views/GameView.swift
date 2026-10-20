//
//  GameView.swift
//  Merko32
//

import SwiftUI

/// Spielbildschirm: Kopfzeile mit Countdown und Abbruch, darunter das 2×2-Raster und der Ziffernblock.
struct GameView: View {
    let session: GameSession
    @State private var isConfirmingAbort = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        if let screen = session.currentScreen {
            VStack(spacing: 16) {
                header(for: screen)
                grid(for: screen)
                Spacer(minLength: 0)
                NumberPadView(
                    isEnabled: session.focusedItemID != nil,
                    onDigit: session.input(digit:),
                    onDelete: session.deleteDigit,
                    onNext: session.focusNext
                )
            }
            .padding()
            .alert("Wirklich abbrechen?", isPresented: $isConfirmingAbort) {
                Button("Ja, abbrechen", role: .destructive) {
                    session.abort()
                }
                Button("Weiterspielen", role: .cancel) {}
            } message: {
                Text("Nicht erreichte Abfragen zählen als falsch.")
            }
        }
    }

    private func header(for screen: Screen) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Bildschirm \(screen.index + 1)/\(session.config.screenCount)")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button("Abbrechen") {
                    isConfirmingAbort = true
                }
                .foregroundStyle(Color(GameColor.red))
                .font(.headline)
            }
            CountdownView(remainingSeconds: session.remainingSeconds, totalSeconds: screen.seconds)
        }
    }

    private func grid(for screen: Screen) -> some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(screen.fields, id: \.item.id) { field in
                FieldView(
                    field: field,
                    input: session.answer(for: field.item.id),
                    isFocused: session.focusedItemID == field.item.id
                )
                .aspectRatio(1.2, contentMode: .fit)
                .onTapGesture {
                    session.focus(id: field.item.id)
                }
            }
        }
    }
}
