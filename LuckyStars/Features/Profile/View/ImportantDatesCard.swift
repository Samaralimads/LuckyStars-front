//
//  ImportantDatesCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 16/02/2026.
//
import SwiftUI

struct ImportantDatesCard: View {
    let anniversary: Date
    @Binding var importantDates: [ImportantDate]
    let onAddDate: () -> Void
    let onDelete: (ImportantDate) -> Void
    let onEdit: (ImportantDate) -> Void
    @Binding var anniversaryReminderDaysBefore: Int?
    @State private var dateToEdit: ImportantDate?
    @State private var showAnniversaryReminder = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("NEVER MISS A MOMENT")
                        .font(.luckyCaptionStrong)
                        .foregroundStyle(Color.luckyBlue)

                    Text("Important Dates")
                        .font(.luckyHeadline)
                        .foregroundStyle(Color.charcoal)
                }

                Spacer()

                Button {
                    onAddDate()
                } label: {
                    Text("Add date")
                        .font(.luckySubheadlineStrong)
                        .foregroundStyle(Color.luckyBlue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.luckyBlueTint))
                }
            }

            List {
                DateRowView(
                    title: "Anniversary",
                    date: anniversary,
                    showsChevron: true,
                    repeatsYearly: true,
                    reminderDaysBefore: anniversaryReminderDaysBefore
                )
                    .contentShape(Rectangle())
                    .onTapGesture { showAnniversaryReminder = true }
                    .accessibilityAddTraits(.isButton)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparatorTint(Color.rowDivider)

                ForEach(importantDates) { date in
                    DateRowView(
                        title: date.label,
                        date: date.date,
                        showsChevron: true,
                        repeatsYearly: date.repeatsYearly,
                        reminderDaysBefore: date.reminderDaysBefore
                    )
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(Color.rowDivider)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                onDelete(date)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                dateToEdit = date
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(Color.luckyBlue)
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .frame(height: CGFloat(min(importantDates.count + 1, 4)) * 112)
            .scrollDisabled(importantDates.count + 1 <= 4)
        }
        .padding(20)
        .luckyCard()
        .padding(.trailing, Outline.shadowOffset)
        .sheet(isPresented: $showAnniversaryReminder) {
            AnniversaryReminderSheet(anniversary: anniversary, daysBefore: $anniversaryReminderDaysBefore)
        }
        .sheet(item: $dateToEdit) { date in
            EditImportantDateSheet(date: date) { updated in
                onEdit(updated)
            }
        }
    }
}

// MARK: - Date Row
struct DateRowView: View {
    let title: String
    let date: Date
    let showsChevron: Bool
    var repeatsYearly: Bool = false
    var reminderDaysBefore: Int? = nil

    /// A yearly date shows its next occurrence; a one-off date shows the stored date.
    private var displayedDate: Date {
        guard repeatsYearly else { return date }
        let calendar = Calendar.current
        let parts = calendar.dateComponents([.month, .day], from: date)
        let startOfToday = calendar.startOfDay(for: .now)
        return calendar.nextDate(
            after: startOfToday.addingTimeInterval(-1),
            matching: parts,
            matchingPolicy: .nextTime
        ) ?? date
    }

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.m) {
            DateBadge(date: displayedDate)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.luckyHeadline)
                    .foregroundStyle(Color.charcoal)
                    .lineLimit(1)

                // The badge already shows day and month, so a yearly date only says "Every year".
                // A one-off date also needs its year, which the badge doesn't show.
                if repeatsYearly {
                    detail(icon: "repeat", text: "Every year")
                } else {
                    detail(icon: "calendar", text: date.formatted(.dateTime.day().month(.abbreviated).year()))
                }

                if let reminderDaysBefore {
                    detail(icon: "bell", text: "Reminder: \(ReminderOption(days: reminderDaysBefore).rowText)")
                }
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.luckyBlue)
            }
        }
        .frame(minHeight: 80)
        .padding(.vertical, 12)
    }

    private func detail(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.luckySubheadline)
        .foregroundStyle(Color.inkSecondary)
    }
}

/// Rounded square with the month on top and the day number below.
private struct DateBadge: View {
    let date: Date

    var body: some View {
        VStack(spacing: 0) {
            Text(date.formatted(.dateTime.month(.abbreviated)).uppercased())
                .font(.luckyCaptionStrong)
                .foregroundStyle(Color.inkSecondary)

            Text(date.formatted(.dateTime.day()))
                .font(.luckyTitle)
                .foregroundStyle(Color.luckyBlue)
        }
        .frame(width: 64, height: 64)
        .background(
            RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
                .fill(Color.luckyBlueTint)
        )
        .accessibilityHidden(true)
    }
}

// MARK: - Reminder choices
private enum ReminderOption: String, CaseIterable, Identifiable {
    case none = "No reminder"
    case onTheDay = "On the day"
    case oneDay = "1 day before"
    case threeDays = "3 days before"
    case sevenDays = "7 days before"

    var id: String { rawValue }

    /// Days before the date; nil means no reminder.
    var days: Int? {
        switch self {
        case .none: nil
        case .onTheDay: 0
        case .oneDay: 1
        case .threeDays: 3
        case .sevenDays: 7
        }
    }

    /// The closest option for a stored number of days (only these options can be saved from the app).
    init(days: Int?) {
        switch days {
        case nil: self = .none
        case 0: self = .onTheDay
        case 1: self = .oneDay
        case 3: self = .threeDays
        case 7: self = .sevenDays
        default: self = .sevenDays
        }
    }

    /// Text after "Reminder: " on a row, e.g. "7 days before" or "on the day".
    var rowText: String {
        self == .onTheDay ? "on the day" : rawValue
    }
}

// MARK: - Add / Edit form
/// Shared by the Add and Edit sheets: Title, Date, Repeat every year, In-app reminder, Save.
private struct ImportantDateForm: View {
    let heading: String
    @Binding var label: String
    @Binding var date: Date
    @Binding var repeatsYearly: Bool
    @Binding var reminder: ReminderOption
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.cardFill.ignoresSafeArea()

            VStack(spacing: 0) {
                LuckySheetHeader(title: heading) { dismiss() }

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        field("Title") {
                            TextField("Title", text: $label)
                                .font(.luckyBody)
                                .foregroundStyle(Color.charcoal)
                        }

                        field("Date") {
                            PickerFieldLabel(
                                text: date.formatted(.dateTime.day().month(.abbreviated).year()),
                                icon: "calendar"
                            ) {
                                DatePicker("Date", selection: $date, displayedComponents: .date)
                            }
                        }

                        Button {
                            repeatsYearly.toggle()
                        } label: {
                            HStack(spacing: Spacing.s) {
                                Checkbox(isOn: repeatsYearly)
                                Text("Repeat every year")
                                    .font(.luckyBody)
                                    .foregroundStyle(Color.charcoal)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(repeatsYearly ? .isSelected : [])

                        field("In-app reminder") {
                            Menu {
                                Picker("In-app reminder", selection: $reminder) {
                                    ForEach(ReminderOption.allCases) { Text($0.rawValue).tag($0) }
                                }
                            } label: {
                                HStack {
                                    Text(reminder.rawValue)
                                        .font(.luckyBody)
                                        .foregroundStyle(Color.charcoal)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.luckyCaptionStrong)
                                        .foregroundStyle(Color.inkSecondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, Spacing.s)
                }

                Button("Save date") {
                    onSave()
                    dismiss()
                }
                .buttonStyle(.luckyPrimary)
                .disabled(label.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.fraction(0.8)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.cardFill)
    }

    private func field<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        FormField(title: title, content: content)
    }
}

// MARK: - Anniversary reminder
/// The anniversary date itself is edited from "Together for"; this sheet only sets its reminder.
private struct AnniversaryReminderSheet: View {
    let anniversary: Date
    @Binding var daysBefore: Int?
    @State private var reminder: ReminderOption
    @Environment(\.dismiss) private var dismiss

    init(anniversary: Date, daysBefore: Binding<Int?>) {
        self.anniversary = anniversary
        self._daysBefore = daysBefore
        self._reminder = State(initialValue: ReminderOption(days: daysBefore.wrappedValue))
    }

    var body: some View {
        ZStack {
            Color.cardFill.ignoresSafeArea()

            VStack(spacing: 0) {
                LuckySheetHeader(title: "Anniversary") { dismiss() }

                VStack(alignment: .leading, spacing: Spacing.m) {
                    Text("Every year on \(anniversary.formatted(.dateTime.day().month(.wide))). To change the date, use Edit in Together for.")
                        .font(.luckyBody)
                        .foregroundStyle(Color.inkSecondary)

                    FormField(title: "In-app reminder") {
                        Menu {
                            Picker("In-app reminder", selection: $reminder) {
                                ForEach(ReminderOption.allCases) { Text($0.rawValue).tag($0) }
                            }
                        } label: {
                            HStack {
                                Text(reminder.rawValue)
                                    .font(.luckyBody)
                                    .foregroundStyle(Color.charcoal)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.luckyCaptionStrong)
                                    .foregroundStyle(Color.inkSecondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, Spacing.s)

                Spacer()

                Button("Save reminder") {
                    daysBefore = reminder.days
                    dismiss()
                }
                .buttonStyle(.luckyPrimary)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.fraction(0.55)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.cardFill)
    }
}

private struct Checkbox: View {
    let isOn: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(isOn ? Color.luckyBlue : Color.cardFill)
            .frame(width: 26, height: 26)
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(isOn ? Color.luckyBlue : Color.fieldBorder, lineWidth: Outline.field)
            )
            .overlay {
                if isOn {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.cardFill)
                }
            }
    }
}

// MARK: - Add Sheet
struct AddImportantDateSheet: View {
    let onAdd: (String, Date, Bool, Int?) -> Void
    @State private var label = ""
    @State private var date = Date()
    @State private var repeatsYearly = false
    @State private var reminder: ReminderOption = .none

    var body: some View {
        ImportantDateForm(
            heading: "Add date",
            label: $label,
            date: $date,
            repeatsYearly: $repeatsYearly,
            reminder: $reminder
        ) {
            onAdd(label, date, repeatsYearly, reminder.days)
        }
    }
}

// MARK: - Edit Sheet
struct EditImportantDateSheet: View {
    let date: ImportantDate
    let onSave: (ImportantDate) -> Void
    @State private var label: String
    @State private var selectedDate: Date
    @State private var repeatsYearly: Bool
    @State private var reminder: ReminderOption

    init(date: ImportantDate, onSave: @escaping (ImportantDate) -> Void) {
        self.date = date
        self.onSave = onSave
        self._label = State(initialValue: date.label)
        self._selectedDate = State(initialValue: date.date)
        self._repeatsYearly = State(initialValue: date.repeatsYearly)
        self._reminder = State(initialValue: ReminderOption(days: date.reminderDaysBefore))
    }

    var body: some View {
        ImportantDateForm(
            heading: "Edit date",
            label: $label,
            date: $selectedDate,
            repeatsYearly: $repeatsYearly,
            reminder: $reminder
        ) {
            var updated = date
            updated.label = label
            updated.date = selectedDate
            updated.repeatsYearly = repeatsYearly
            updated.reminderDaysBefore = reminder.days
            onSave(updated)
        }
    }
}

#Preview {
    @Previewable @State var importantDates: [ImportantDate] = []

    Background {
        ImportantDatesCard(
            anniversary: Date(),
            importantDates: $importantDates,
            onAddDate: {},
            onDelete: { _ in },
            onEdit: { _ in },
            anniversaryReminderDaysBefore: .constant(nil)
        )
        .padding(20)
    }
}
