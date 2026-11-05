//
//  TogetherForCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 16/02/2026.
//
import SwiftUI

struct TogetherForCard: View {
    let anniversary: Date
    let onEdit: () -> Void
    
    var timeComponents: (years: Int, months: Int, days: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: anniversary, to: Date())
        return (components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SINCE \(anniversary.formatted(.dateTime.day().month(.abbreviated).year()).uppercased())")
                        .font(.luckyCaptionStrong)
                        .foregroundStyle(Color.luckyBlue)

                    Text("Together for")
                        .font(.luckyHeadline)
                        .foregroundStyle(Color.charcoal)
                }

                Spacer()

                Button {
                    onEdit()
                } label: {
                    Text("Edit")
                        .font(.luckySubheadlineStrong)
                        .foregroundStyle(Color.luckyBlue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.luckyBlueTint))
                }
            }

            HStack(spacing: Spacing.s) {
                TimeUnitView(value: String(format: "%02d", timeComponents.years), label: timeComponents.years == 1 ? "Year" : "Years")
                TimeUnitView(value: String(format: "%02d", timeComponents.months), label: timeComponents.months == 1 ? "Month" : "Months")
                TimeUnitView(value: String(format: "%02d", timeComponents.days), label: timeComponents.days == 1 ? "Day" : "Days")
            }
        }
        .padding(20)
        .luckyCard()
        .padding(.trailing, Outline.shadowOffset)
    }
}

struct TimeUnitView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.luckyTitle)
                .foregroundStyle(Color.luckyBlue)
            Text(label.uppercased())
                .font(.luckyCaptionStrong)
                .foregroundStyle(Color.charcoal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
                .strokeBorder(Color.charcoal, lineWidth: Outline.thick)
        )
    }
}

// MARK: - Edit Anniversary Sheet
struct EditAnniversarySheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var anniversary: Date
    /// Saves the date; returns nil on success, or the message to show when it failed.
    let onSave: (Date) async -> String?
    @State private var tempDate: Date
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    init(anniversary: Binding<Date>, onSave: @escaping (Date) async -> String?) {
        self._anniversary = anniversary
        self.onSave = onSave
        self._tempDate = State(initialValue: anniversary.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker("Anniversary Date", selection: $tempDate, in: ...Date.now, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()

                if let errorMessage {
                    Text(errorMessage)
                        .font(.luckySubheadline)
                        .foregroundStyle(Color.destructiveRed)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Edit Anniversary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Saving..." : "Save") {
                        Task {
                            isSaving = true
                            errorMessage = nil
                            if let failure = await onSave(tempDate) {
                                // Keep the sheet open and the old date: nothing was saved.
                                errorMessage = failure
                            } else {
                                anniversary = tempDate
                                dismiss()
                            }
                            isSaving = false
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .presentationDetents([.medium])
    }
}


