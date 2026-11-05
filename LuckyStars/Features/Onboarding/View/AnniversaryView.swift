//
//  AnniversaryView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 10/02/2026.
//

import SwiftUI

struct AnniversaryView: View {
    @State private var anniversary: Date? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @Environment(AppState.self) private var appState

    var body: some View {
        Background {
            WhiteCard(title: "How long have you been together?", description: "Choose the date your journey began. We'll use it to celebrate your milestones.") {

                InputField(placeholder: "Together since:", date: $anniversary)
                    .padding(.vertical, Spacing.l)

                if let error = errorMessage {
                    Text(error)
                        .font(.luckySubheadline)
                        .foregroundStyle(Color.destructiveRed)
                        .multilineTextAlignment(.center)
                }

                Button("Done") {
                    Task {
                        guard let date = anniversary else { return }
                        isLoading = true
                        errorMessage = nil
                        do {
                            _ = try await CoupleService.createCouple(anniversaryDate: date)
                            appState.completeOnboarding()
                        } catch {
                            print("Create couple error: \(error)")
                            errorMessage = "Something went wrong. Please try again."
                        }
                        isLoading = false
                    }
                }
                .buttonStyle(.luckyPrimary)
                .disabled(anniversary == nil)
                .luckyLoading(isLoading)
            }
        }
        .luckyBackButton()
    }
}

#Preview {
    AnniversaryView()
        .environment(AppState())
}
