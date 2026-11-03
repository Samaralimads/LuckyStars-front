//
//  AppleSignInButton.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 25/10/2026.
//
//  Placeholder "Sign in / Sign up with Apple" button. No logic yet.
//

import SwiftUI

struct AppleSignInButton: View {
    let title: String
    var action: () -> Void = {
        // TODO: Implement Sign in with Apple
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.s) {
                Image(systemName: "apple.logo")
                Text(title)
            }
        }
        .buttonStyle(.luckySecondary)
    }
}

#Preview {
    AppleSignInButton(title: "Sign in with Apple")
        .padding()
        .background(Color.cardFill)
}
