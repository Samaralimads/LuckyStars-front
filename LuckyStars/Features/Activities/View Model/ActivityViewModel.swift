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

    // MARK: - Load everything on appear
    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let fetchedCategories = ActivityService.fetchCategories()
            async let fetchedActivities = ActivityService.fetchActivities()
            categories = Self.displayOrder(try await fetchedCategories)
            activities = try await fetchedActivities
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Apply filters and search
    func applyFilters() async {
        isLoading = true
        errorMessage = nil

        do {
            activities = try await ActivityService.fetchActivities(
                category: selectedCategoryName,
                search: searchText.isEmpty ? nil : searchText,
                budget: filterState.priceRange,
                duration: filterState.duration,
                location: filterState.location
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
