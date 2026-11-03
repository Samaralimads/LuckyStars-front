//
//  StatsViewModel.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 28/09/2026.
//

import Foundation

@Observable
class StatsViewModel {
    var isLoading = false
    var myName = ""
    var partnerName = ""
    var totalCompleted = 0
    var plannedByMe = 0
    var plannedByPartner = 0
    var indoorCount = 0
    var outdoorCount = 0

    var isPaired: Bool { !partnerName.isEmpty }

    // MARK: - Load
    func load() async {
        isLoading = true
        defer { isLoading = false }

        guard
            let user = try? await ProfileService.fetchMe(),
            let planned = try? await PlannedActivityService.getCoupleActivities()
        else { return }

        myName = user.firstName
        partnerName = (try? await ProfileService.fetchCouple())?.partner?.firstName ?? ""

        let now = Date.now
        let completed = planned.filter { $0.isAccepted && ($0.parsedDate ?? .distantFuture) <= now }

        totalCompleted = completed.count
        plannedByMe = completed.filter { $0.plannedByUserId == user.id }.count
        plannedByPartner = totalCompleted - plannedByMe

        let activityIds = Set(completed.map(\.activityId))
        var indoorById: [UUID: Bool] = [:]

        await withTaskGroup(of: (UUID, Bool?).self) { group in
            for id in activityIds {
                group.addTask {
                    let activity = try? await ActivityService.fetchActivity(id: id)
                    return (id, activity?.isIndoor)
                }
            }
            for await (id, isIndoor) in group {
                if let isIndoor {
                    indoorById[id] = isIndoor
                }
            }
        }

        indoorCount = completed.filter { indoorById[$0.activityId] == true }.count
        outdoorCount = completed.filter { indoorById[$0.activityId] == false }.count
    }
}
