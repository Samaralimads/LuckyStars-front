//
//  LuckyButtonStyles.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 27/10/2026.
//
//  Primary, secondary and destructive button styles.
//

import SwiftUI

// MARK: - Loading state
private struct LuckyIsLoadingKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var luckyIsLoading: Bool {
        get { self[LuckyIsLoadingKey.self] }
        set { self[LuckyIsLoadingKey.self] = newValue }
    }
}

extension View {
    /// While `isLoading`, the button shows a spinner in place of its label (same size, so nothing
    /// jumps) and can't be tapped again. Put it after `.buttonStyle(...)`.
    func luckyLoading(_ isLoading: Bool) -> some View {
        environment(\.luckyIsLoading, isLoading)
            .disabled(isLoading)
    }
}

/// The button's label, replaced by a spinner while loading. The label stays in the layout (hidden)
/// so the button keeps its width.
private struct LuckyButtonLabel<Label: View>: View {
    let label: Label
    let spinnerColor: Color
    @Environment(\.luckyIsLoading) private var isLoading

    var body: some View {
        label
            .opacity(isLoading ? 0 : 1)
            .overlay {
                if isLoading {
                    ProgressView().tint(spinnerColor)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: isLoading)
    }
}

/// Solid charcoal pill with cream-white text. `compact` hugs its text instead of filling the width.
struct LuckyPrimaryButtonStyle: ButtonStyle {
    var compact = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luckyIsLoading) private var isLoading

    func makeBody(configuration: Configuration) -> some View {
        LuckyButtonLabel(label: configuration.label, spinnerColor: .cardFill)
            .font(compact ? .luckyLabel : .luckyButton)
            .foregroundStyle(Color.cardFill)
            .padding(.horizontal, compact ? 20 : 0)
            .frame(maxWidth: compact ? nil : .infinity)
            .frame(height: compact ? 40 : 48)
            .background(Capsule().fill(Color.charcoal))
            .opacity(isEnabled || isLoading ? (configuration.isPressed ? 0.85 : 1) : 0.7)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Cream-white pill with a charcoal outline. `compact` hugs its text instead of filling the width.
struct LuckySecondaryButtonStyle: ButtonStyle {
    var compact = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luckyIsLoading) private var isLoading

    func makeBody(configuration: Configuration) -> some View {
        LuckyButtonLabel(label: configuration.label, spinnerColor: .charcoal)
            .font(compact ? .luckyLabel : .luckyButton)
            .foregroundStyle(Color.charcoal)
            .padding(.horizontal, compact ? 20 : 0)
            .frame(maxWidth: compact ? nil : .infinity)
            .frame(height: compact ? 40 : 48)
            .background(Capsule().fill(Color.cardFill))
            .overlay(Capsule().strokeBorder(Color.charcoal, lineWidth: Outline.thick))
            .opacity(isEnabled || isLoading ? (configuration.isPressed ? 0.85 : 1) : 0.6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Sign out, Delete account, Unpair partner: red text on a charcoal-outlined pill.
struct LuckyDestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luckyIsLoading) private var isLoading

    func makeBody(configuration: Configuration) -> some View {
        LuckyButtonLabel(label: configuration.label, spinnerColor: .destructiveRed)
            .font(.luckyBodyStrong)
            .foregroundStyle(Color.destructiveRed)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Capsule().fill(Color.cardFill))
            .overlay(Capsule().strokeBorder(Color.charcoal, lineWidth: 1.5))
            .opacity(isEnabled || isLoading ? (configuration.isPressed ? 0.85 : 1) : 0.6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == LuckyPrimaryButtonStyle {
    static var luckyPrimary: LuckyPrimaryButtonStyle { .init() }
    static var luckyPrimaryCompact: LuckyPrimaryButtonStyle { .init(compact: true) }
}

extension ButtonStyle where Self == LuckySecondaryButtonStyle {
    static var luckySecondary: LuckySecondaryButtonStyle { .init() }
    static var luckySecondaryCompact: LuckySecondaryButtonStyle { .init(compact: true) }
}

extension ButtonStyle where Self == LuckyDestructiveButtonStyle {
    static var luckyDestructive: LuckyDestructiveButtonStyle { .init() }
}

#Preview {
    VStack(spacing: 16) {
        Button("Create Account") {}.buttonStyle(.luckyPrimary)
        Button("Log In") {}.buttonStyle(.luckySecondary)
        Button("Sign out") {}.buttonStyle(.luckyDestructive)
        Button("Disabled") {}.buttonStyle(.luckyPrimary).disabled(true)
        Button("Loading") {}.buttonStyle(.luckyPrimary).luckyLoading(true)
        Button("Loading") {}.buttonStyle(.luckySecondary).luckyLoading(true)
        Button("Loading") {}.buttonStyle(.luckyDestructive).luckyLoading(true)
    }
    .padding()
    .background { Image("LuckyBackground").resizable().scaledToFill().ignoresSafeArea() }
}
