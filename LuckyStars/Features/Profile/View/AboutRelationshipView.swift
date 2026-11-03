//
//  AboutRelationshipView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 13/02/2026.
//

import SwiftUI

struct AboutRelationshipView: View {
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        Background{

            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.isPaired {
                    PartnerView(viewModel: viewModel)
                } else {
                    NoPartnerView()
                }
            }
        }
        .luckyBackButton(title: "Your Relationship")
        .task { await viewModel.load() }
    }
}


struct PartnerView: View {
    let viewModel: ProfileViewModel
    @State private var showUnpairAlert = false
    @State private var showUnpairUnavailableAlert = false

    var body: some View {

        ScrollView {
            VStack(spacing: 20) {
                LuckyGroup {
                    HStack {
                        Text("Partner")
                            .font(.luckyBodyStrong)
                            .foregroundStyle(Color.charcoal)

                        Spacer()

                        Text(viewModel.couple?.partner?.firstName ?? "")
                            .font(.luckyBody)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Color.inkSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 22)

                    HStack {
                        Text("Together Since")
                            .font(.luckyBodyStrong)
                            .foregroundStyle(Color.charcoal)

                        Spacer()

                        Text(viewModel.anniversaryDate, style: .date)
                            .font(.luckyBody)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Color.inkSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 22)
                }

                Button {
                    showUnpairAlert = true
                } label: {
                    Text("Unpair partner")
                }
                .buttonStyle(.luckyDestructive)
                .padding(.trailing, Outline.shadowOffset)
                .alert("Unpair Partner", isPresented: $showUnpairAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Unpair", role: .destructive) {
                        // Unpairing isn't implemented on the backend yet.
                        showUnpairUnavailableAlert = true
                    }
                } message: {
                    Text("Are you sure you want to unpair from \(viewModel.couple?.partner?.firstName ?? "your partner")? You'll need to pair again to reconnect.")
                }
                .alert("Not Available Yet", isPresented: $showUnpairUnavailableAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Unpairing isn't supported yet — it's on the list.")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }
}

struct NoPartnerView: View{

    var body: some View {

        WhiteCard(title: "You are not paired", description:"You haven’t connected with your partner yet. Pair up to view your relationship details, track milestones, and plan meaningful moments together.") {


            NavigationLink("Invite my partner") {
                ShareCodePairingView()
            }
            .buttonStyle(.luckyPrimary)
            .padding(.top, Spacing.l)

        }

    }
}

#Preview {
    AboutRelationshipView()
}
