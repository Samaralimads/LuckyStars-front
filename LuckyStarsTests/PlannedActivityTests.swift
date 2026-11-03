//
//  PlannedActivityTests.swift
//  LuckyStarsTests
//
//  Created by Samara Lima da Silva on 30/09/2026.
//

import XCTest
@testable import LuckyStars

final class PlannedActivityTests: XCTestCase {

    private func makeActivity(status: String, date: String) -> PlannedActivity {
        PlannedActivity(
            id: UUID(),
            activityId: UUID(),
            activityTitle: "Pottery class",
            coupleId: UUID(),
            plannedByUserId: UUID(),
            proposedDate: date,
            responseDate: nil,
            bookingStatus: status,
            reminderEnabled: false,
            reminderDaysBefore: nil,
            note: nil,
            createdAt: nil
        )
    }

    func testParsedDateMatchesUTCFormat() {
        let activity = makeActivity(status: "pending", date: "2026-10-05 18:00")

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: activity.parsedDate!)

        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 10)
        XCTAssertEqual(components.day, 5)
        XCTAssertEqual(components.hour, 18)
    }

    func testParsedDateIsNilForInvalidFormat() {
        let activity = makeActivity(status: "pending", date: "not-a-date")
        XCTAssertNil(activity.parsedDate)
    }

    func testBookingStatusFlags() {
        XCTAssertTrue(makeActivity(status: "pending", date: "2026-10-05 18:00").isPending)
        XCTAssertFalse(makeActivity(status: "pending", date: "2026-10-05 18:00").isAccepted)
        XCTAssertTrue(makeActivity(status: "accepted", date: "2026-10-05 18:00").isAccepted)
        XCTAssertFalse(makeActivity(status: "accepted", date: "2026-10-05 18:00").isPending)
    }
}
