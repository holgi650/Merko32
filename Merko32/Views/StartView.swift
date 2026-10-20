//
//  StartView.swift
//  Merko32
//

import SwiftUI

/// Startbildschirm: nur ein Start-Button.
struct StartView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 48) {
            Spacer()
            Text("Merko32")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Button(action: onStart) {
                Text("Start")
                    .font(.title.bold())
                    .frame(maxWidth: 240, minHeight: 64)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(GameColor.blue))
            Spacer()
        }
        .padding()
    }
}

#Preview {
    StartView(onStart: {})
        .background(Color.appBackground)
}
