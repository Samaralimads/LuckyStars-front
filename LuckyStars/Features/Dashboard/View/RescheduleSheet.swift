//
//  RescheduleSheet.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 09/07/2026.
//

import SwiftUI

struct RescheduleSheet: View {
    let proposal: PlannedActivity
    let partnerName: String
    let onSend: (Date, String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var newDate: Date
    @State private var newTime: Date
    @State private var note = ""

    init(proposal: PlannedActivity, partnerName: String, onSend: @escaping (Date, String?) -> Void) {
        self.proposal = proposal
        self.partnerName = partnerName
        self.onSend = onSend

        // Start from the partner's suggestion instead of the current moment
        let start = proposal.parsedDate ?? .now
        _newDate = State(initialValue: start)
        _newTime = State(initialValue: start)
    }

    var body: some View {
        ZStack {
            Color.cardFill.ignoresSafeArea()

            VStack(spacing: 0) {
                LuckySheetHeader(title: "Propose new time") { dismiss() }

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(proposal.activityTitle)
                                .font(.luckyHeadline)
                                .foregroundStyle(Color.charcoal)

                            if let originalDate = proposal.parsedDate {
                                Text("\(partnerName) suggested \(originalDate.formatted(.dateTime.month(.abbreviated).day())) · \(originalDate.formatted(.dateTime.hour().minute()))")
                                    .font(.luckySubheadline)
                                    .foregroundStyle(Color.inkSecondary)
                            }
                        }

                        FormField(title: "Date") {
                            PickerFieldLabel(
                                text: newDate.formatted(.dateTime.day().month(.abbreviated).year()),
                                icon: "calendar"
                            ) {
                                DatePicker("Date", selection: $newDate, displayedComponents: .date)
                            }
                        }

                        FormField(title: "Time") {
                            PickerFieldLabel(
                                text: newTime.formatted(.dateTime.hour().minute()),
                                icon: "clock"
                            ) {
                                DatePicker("Time", selection: $newTime, displayedComponents: .hourAndMinute)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note")
                                .font(.luckyBodySemibold)
                                .foregroundStyle(Color.charcoal)

                            TextField("Add a note for \(partnerName) (optional)", text: $note, axis: .vertical)
                                .font(.luckyBody)
                                .foregroundStyle(Color.charcoal)
                                .lineLimit(3...)
                                .padding(18)
                                .background(
                                    RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
                                        .fill(Color.cardFill)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
                                        .strokeBorder(Color.fieldBorder, lineWidth: Outline.field)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, Spacing.s)
                }

                HStack(spacing: Spacing.s) {
                    Button("Cancel") { dismiss() }
                        .buttonStyle(.luckySecondary)

                    Button("Send proposal", action: sendProposal)
                        .buttonStyle(.luckyPrimary)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.cardFill)
    }

    // MARK: - Actions
    private func sendProposal() {
        let combined = combinedDate(date: newDate, time: newTime)
        onSend(combined, note.isEmpty ? nil : note)
        dismiss()
    }

    private func combinedDate(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        return calendar.date(from: components) ?? date
    }
}

#Preview {
    RescheduleSheet(
        proposal: PlannedActivity(
            id: UUID(),
            activityId: UUID(),
            activityTitle: "Picnic at the Park",
            coupleId: UUID(),
            plannedByUserId: UUID(),
            proposedDate: "2026-07-10 18:30",
            responseDate: nil,
            bookingStatus: "pending",
            reminderEnabled: false,
            reminderDaysBefore: nil,
            note: "Bring the blanket!",
            createdAt: nil
        ),
        partnerName: "Alex"
    ) { _, _ in }
}
