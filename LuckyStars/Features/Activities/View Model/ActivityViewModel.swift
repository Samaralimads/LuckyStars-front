//
//  ActivityViewModel.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 18/05/2026.
//

import Foundation

@Observable
class ActivityViewModel {
    var activities: [Activity] = []
    var categories: [Category] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var selectedCategoryName: String? = nil
    var searchText: String = ""
    var filterState: FilterState = FilterState()

    // MARK: - Category order
    // The API returns categories alphabetically; this is the order shown in the chip row.
    // Categories not listed here (e.g. new ones) keep the API order, after these.
    private static let categoryOrder = ["Food & Drinks", "Nature", "Creative", "Culture", "Active"]

    private static func displayOrder(_ categories: [Category]) -> [Category] {
        func rank(_ category: Category) -> Int {
            categoryOrder.firstIndex(of: category.name) ?? categoryOrder.count
        }
        // sorted(by:) isn't stable, so the original index breaks ties.
        return categories.enumerated()
            .sorted { (rank($0.element), $0.offset) < (rank($1.element), $1.offset) }
            .map(\.element)
    }

    // Bumped by every refresh so an older, slower response never overwrites a newer one.
    private var latestRequest = 0

    // MARK: - Load everything on appear
    func load() async {
        await refresh()
    }

    // MARK: - Apply filters and search
    func applyFilters() async {
        await refresh()
    }

    /// Fetches the activities for the current category, search text and filters
    /// (plus the categories the first time), so reloading never drops the user's filters.
    private func refresh() async {
        latestRequest += 1
        let request = latestRequest
        isLoading = true
        errorMessage = nil

        do {
            if categories.isEmpty {
                categories = Self.displayOrder(try await ActivityService.fetchCategories())
            }
            let fetched = try await ActivityService.fetchActivities(
                category: selectedCategoryName,
                search: searchText.isEmpty ? nil : searchText,
                budget: filterState.priceRange,
                duration: filterState.duration,
                location: filterState.location
            )
            guard request == latestRequest else { return }
            activities = fetched
        } catch {
            guard request == latestRequest, !error.isCancellation else { return }
            errorMessage = error.localizedDescription
        }

        if request == latestRequest { isLoading = false }
    }
}
