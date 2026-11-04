//
//  StatsViewModel.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 28/09/2026.
//

import Foundation

enum StatsRange: String, CaseIterable, Identifiable {
    case thisMonth = "This month"
    case thisYear = "This year"
    case allTime = "All time"

    var id: String { rawValue }
}

@Observable
class StatsViewModel {
    var isLoading = false
    var errorMessage: String? = nil
    var myName = ""
    var partnerName = ""
    var totalCompleted = 0
    var plannedByMe = 0
    var plannedByPartner = 0

    /// Choosing a range recomputes from the data already loaded, no new request.
    var range: StatsRange = .thisYear {
        didSet { recompute() }
    }

    private var completed: [PlannedActivity] = []
    private var userId: UUID? = nil

    var isPaired: Bool { !partnerName.isEmpty }

    // MARK: - Load
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = try await ProfileService.fetchMe()
            let planned = try await PlannedActivityService.getCoupleActivities()

            userId = user.id
            myName = user.firstName
            partnerName = (try? await ProfileService.fetchCouple())?.partner?.firstName ?? ""

            let now = Date.now
            completed = planned.filter { $0.isAccepted && ($0.parsedDate ?? .distantFuture) <= now }
            recompute()
        } catch {
            guard !error.isCancellation else { return }
            print("Stats error: \(error)")
            errorMessage = "Couldn't load your stats."
        }
    }

    // MARK: - Range
    private func recompute() {
        let calendar = Calendar.current
        let now = Date.now

        let inRange = completed.filter { planned in
            guard let date = planned.parsedDate else { return false }
            switch range {
            case .thisMonth: return calendar.isDate(date, equalTo: now, toGranularity: .month)
            case .thisYear:  return calendar.isDate(date, equalTo: now, toGranularity: .year)
            case .allTime:   return true
            }
        }

        totalCompleted = inRange.count
        plannedByMe = inRange.filter { $0.plannedByUserId == userId }.count
        plannedByPartner = totalCompleted - plannedByMe
    }
}
