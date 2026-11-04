//
//  ActivityView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 17/02/2026.
//

import SwiftUI

struct ActivityView: View {
    @State private var viewModel = ActivityViewModel()
    @State private var showFilters = false

    var body: some View {
        Background {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Discover")
                        .font(.luckyScreenTitle)
                        .foregroundStyle(Color.charcoal)
                        .padding(.leading, Spacing.xs)

                    searchBar
                    categoriesRow
                    listOfActivities
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - Components
private extension ActivityView {

    var searchBar: some View {
        HStack(spacing: 12) {
            HStack {
                TextField("", text: $viewModel.searchText, prompt: Text("Search an activity").foregroundStyle(Color.placeholderGrey))
                    .textFieldStyle(.plain)
                    .font(.luckyBody)
                    .foregroundStyle(Color.charcoal)
                    .onSubmit {
                        Task { await viewModel.applyFilters() }
                    }

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                        Task { await viewModel.applyFilters() }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.placeholderGrey)
                    }
                }

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.charcoal)
            }
            .padding(.horizontal, 20)
            .frame(height: 52)
            .luckyOutline(Capsule())

            Button {
                showFilters = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(Color.charcoal)
                        .frame(width: 52, height: 52)
                        .luckyOutline(Circle())

                    if viewModel.filterState.totalSelected > 0 {
                        Text("\(viewModel.filterState.totalSelected)")
                            .font(.luckyCaptionStrong)
                            .foregroundStyle(Color.cardFill)
                            .frame(width: 22, height: 22)
                            .background(Color.luckyBlue)
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(Color.charcoal, lineWidth: 1.5))
                            .offset(x: 4, y: -4)
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FiltersView(filterState: $viewModel.filterState)
                    .presentationDetents([.fraction(0.75)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color.cardFill)
                    .onDisappear {
                        Task { await viewModel.applyFilters() }
                    }
            }
        }
        .padding(.trailing, 3)
    }

    var categoriesRow: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                categoryChip(title: "All", isSelected: viewModel.selectedCategoryName == nil, imageName: "Sparkles") {
                    viewModel.selectedCategoryName = nil
                    Task { await viewModel.applyFilters() }
                }

                ForEach(viewModel.categories) { category in
                    categoryChip(
                        title: category.name,
                        isSelected: viewModel.selectedCategoryName == category.name,
                        imageName: category.imageName
                    ) {
                        viewModel.selectedCategoryName = category.name
                        Task { await viewModel.applyFilters() }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    func categoryChip(title: String, isSelected: Bool, imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: 76, height: 72)
                    .luckyOutline(
                        RoundedRectangle(cornerRadius: Radius.tile, style: .continuous),
                        stroke: isSelected ? Color.charcoal : Color.inkSecondary,
                        lineWidth: isSelected ? 3 : Outline.thick,
                        shadowOffset: isSelected ? nil : 0
                    )

                Text(title)
                    .font(isSelected ? .luckySubheadlineStrong : .luckySubheadline)
                    .foregroundStyle(isSelected ? Color.charcoal : Color.inkSecondary)
            }
        }
        .buttonStyle(.plain)
    }

    var listOfActivities: some View {
        Group {
            if viewModel.isLoading && viewModel.activities.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .font(.luckySubheadline)
                    .foregroundStyle(Color.destructiveRed)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else if viewModel.activities.isEmpty {
                // TODO: Replace this text-only empty state with a cute illustration or animation.
                Text("No activities found.")
                    .font(.luckyBody)
                    .foregroundStyle(Color.inkSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.activities) { activity in
                        NavigationLink(destination: ActivityDetailView(activity: activity)) {
                            ActivityCard(activity: activity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    ActivityView()
}
