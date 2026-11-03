//
//  ProfileViewModel.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 20/05/2026.
//

import Foundation
import SwiftUI

@Observable
class ProfileViewModel {
    var user: User? = nil
    var couple: Couple? = nil
    var importantDates: [ImportantDate] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isPaired: Bool { couple?.partner != nil }
    var isSaving: Bool = false
    var saveError: String? = nil
    var isDeleting: Bool = false
    var deleteError: String? = nil

    // MARK: - Load all profile data
    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            user = try await ProfileService.fetchMe()
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            couple = try await ProfileService.fetchCouple()
        } catch {
            couple = nil
        }

        do {
            let dates = try await ProfileService.fetchImportantDates()
            importantDates = dates.map { importantDate(from: $0) }
        } catch {
            importantDates = []
        }

        isLoading = false
    }

    // MARK: - Save profile
    func saveProfile(firstName: String, email: String) async {
        isSaving = true
        saveError = nil
        defer { isSaving = false }

        do {
            user = try await ProfileService.updateMe(
                firstName: firstName.isEmpty ? nil : firstName,
                email: email.isEmpty ? nil : email
            )
        } catch let error as APIError {
            saveError = error.errorDescription ?? "Could not save your changes. Please try again."
        } catch {
            saveError = "Could not save your changes. Please try again."
        }
    }

    // MARK: - Delete account
    func deleteAccount() async -> Bool {
        isDeleting = true
        deleteError = nil
        defer { isDeleting = false }

        do {
            try await APIClient.shared.requestEmpty("/users/me", method: "DELETE")
            return true
        } catch {
            print("Delete account error: \(error)")
            deleteError = "Could not delete your account. Please try again."
            return false
        }
    }

    // MARK: - Add important date
    func addImportantDate(label: String, date: Date, repeatsYearly: Bool, reminderDaysBefore: Int?) async {
        let formatter = dateFormatter()
        do {
            let response = try await ProfileService.createImportantDate(
                label: label,
                date: formatter.string(from: date),
                repeatYearly: repeatsYearly,
                reminderDaysBefore: reminderDaysBefore
            )
            importantDates.append(importantDate(from: response))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update important date
    func updateImportantDate(_ importantDate: ImportantDate) async {
        let formatter = dateFormatter()
        do {
            let response = try await ProfileService.updateImportantDate(
                id: importantDate.id,
                label: importantDate.label,
                date: formatter.string(from: importantDate.date),
                repeatYearly: importantDate.repeatsYearly,
                reminderDaysBefore: importantDate.reminderDaysBefore
            )
            if let index = importantDates.firstIndex(where: { $0.id == importantDate.id }) {
                importantDates[index] = self.importantDate(from: response)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete important date
    func deleteImportantDate(_ importantDate: ImportantDate) async {
        do {
            try await ProfileService.deleteImportantDate(id: importantDate.id)
            importantDates.removeAll { $0.id == importantDate.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers
    private func importantDate(from response: ProfileService.ImportantDateResponse) -> ImportantDate {
        ImportantDate(
            id: response.id,
            label: response.label,
            date: parsedDate(response.date),
            repeatsYearly: response.repeatYearly ?? false,
            reminderDaysBefore: (response.reminderEnabled ?? false) ? response.reminderDaysBefore : nil
        )
    }

    var anniversaryDate: Date {
        guard let dateString = couple?.relationshipStartDate else { return Date.now }
        return parsedDate(dateString)
    }

    var partner1Initial: String {
        String((user?.firstName ?? "?").prefix(1).uppercased())
    }

    var partner2Initial: String? {
        guard let partnerName = couple?.partner?.firstName else { return nil }
        return String(partnerName.prefix(1).uppercased())
    }

    var displayName: String {
        guard let user else { return "" }
        if let partner = couple?.partner {
            return "\(user.firstName) & \(partner.firstName)"
        }
        return user.firstName
    }

    private func dateFormatter() -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }

    private func parsedDate(_ string: String) -> Date {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "UTC")
        return f.date(from: string) ?? Date.now
    }
}
