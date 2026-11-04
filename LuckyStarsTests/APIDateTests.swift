//
//  APIDateTests.swift
//  LuckyStarsTests
//

import XCTest
@testable import LuckyStars

final class APIDateTests: XCTestCase {

    func testDayRoundTripKeepsTheCalendarDay() throws {
        let date = try XCTUnwrap(APIDate.day(from: "2026-03-14"))
        XCTAssertEqual(APIDate.dayString(from: date), "2026-03-14")
    }

    func testDayIsLocalMidnightSoTheDayNeverShifts() throws {
        let date = try XCTUnwrap(APIDate.day(from: "2026-03-14"))
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: date)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 3)
        XCTAssertEqual(components.day, 14)
        XCTAssertEqual(components.hour, 0)
    }

    func testLateEveningLocalTimeStillSendsTheSameDay() {
        var components = DateComponents(year: 2026, month: 3, day: 14, hour: 23, minute: 30)
        components.calendar = Calendar.current
        let date = components.date!
        XCTAssertEqual(APIDate.dayString(from: date), "2026-03-14")
    }

    func testDateTimeIsUTC() throws {
        let date = try XCTUnwrap(APIDate.dateTime(from: "2026-03-14 18:30"))
        XCTAssertEqual(date.timeIntervalSince1970, 1_773_513_000)
        XCTAssertEqual(APIDate.dateTimeString(from: date), "2026-03-14 18:30")
    }

    func testInvalidStringsReturnNil() {
        XCTAssertNil(APIDate.day(from: "14/03/2026"))
        XCTAssertNil(APIDate.dateTime(from: "not a date"))
    }
}

final class DurationTextTests: XCTestCase {

    func testDurationText() {
        XCTAssertEqual(InfoTags.durationText(minutes: 30), "30 min")
        XCTAssertEqual(InfoTags.durationText(minutes: 60), "1h")
        XCTAssertEqual(InfoTags.durationText(minutes: 90), "1h 30m")
        XCTAssertEqual(InfoTags.durationText(minutes: 180), "3h")
    }
}
