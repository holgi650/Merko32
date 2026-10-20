//
//  ResultView.swift
//  Merko32
//

import SwiftUI

/// Auswertung: Kennzahlen, Liste aller Abfragen in Abfragereihenfolge und „Neuer Durchlauf“.
struct ResultView: View {
    let result: GameResult
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Auswertung")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            summary

            ScrollView {
                LazyVStack(spacing: 0) {
                    columnHeader
                    ForEach(Array(result.entries.enumerated()), id: \.element.id) { index, entry in
                        ResultRow(position: index + 1, entry: entry)
                        Divider().overlay(.white.opacity(0.1))
                    }
                }
            }

            Button(action: onRestart) {
                Text("Neuer Durchlauf")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(GameColor.blue))
        }
        .padding()
    }

    private var summary: some View {
        HStack(spacing: 12) {
            SummaryTile(value: "\(result.correctCount)", label: "richtig", color: Color(GameColor.green))
            SummaryTile(value: "\(result.wrongCount)", label: "falsch", color: Color(GameColor.red))
            SummaryTile(value: "\(result.percent) %", label: "Quote", color: .white)
        }
    }

    private var columnHeader: some View {
        HStack {
            Text("#").frame(width: 28, alignment: .leading)
            Text("Symbol").frame(width: 56)
            Text("Zahl").frame(maxWidth: .infinity)
            Text("Eingabe").frame(maxWidth: .infinity)
            Spacer().frame(width: 28)
        }
        .font(.caption.bold())
        .foregroundStyle(.white.opacity(0.6))
        .padding(.vertical, 6)
        .accessibilityHidden(true)
    }
}

private struct SummaryTile: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.08)))
        .accessibilityElement(children: .combine)
    }
}

private struct ResultRow: View {
    let position: Int
    let entry: QueryResult

    private var combination: Combination { entry.item.combination }
    private var isCorrect: Bool { entry.outcome.isCorrect }

    var body: some View {
        HStack {
            Text("\(position)")
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 28, alignment: .leading)
            Image(systemName: combination.symbol.systemName)
                .font(.title2)
                .foregroundStyle(Color(combination.color))
                .frame(width: 56)
            Text("\(entry.item.number)")
                .font(.title3.bold())
                .monospacedDigit()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
            Text(entry.displayInput)
                .font(entry.outcome == .notReached ? .footnote : .title3)
                .monospacedDigit()
                .foregroundStyle(isCorrect ? .white : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
            Image(systemName: isCorrect ? "checkmark" : "xmark")
                .font(.headline)
                .foregroundStyle(Color(isCorrect ? GameColor.green : GameColor.red))
                .frame(width: 28)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        let verdict = isCorrect ? "richtig" : "falsch"
        return "\(position). \(combination.accessibilityLabel), Zahl \(entry.item.number), Eingabe \(entry.displayInput), \(verdict)"
    }
}

#Preview {
    var rng = SystemRandomNumberGenerator()
    let run = RunGenerator.make(config: .standard, using: &rng)
    let answers = Dictionary(uniqueKeysWithValues: run.items.prefix(20).map { ($0.id, String($0.number)) })
    ResultView(result: Scoring.evaluate(run: run, answers: answers, reachedScreenCount: 12), onRestart: {})
        .background(Color.appBackground)
}
