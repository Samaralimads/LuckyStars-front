//
//  FormField.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 29/10/2026.
//
//  A label above a rounded, grey-outlined field, for the forms in sheets.
//

import SwiftUI

struct FormField<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.luckyBodySemibold)
                .foregroundStyle(Color.charcoal)

            content
                .padding(.horizontal, 18)
                .frame(minHeight: 48)
                .background(Capsule().fill(Color.cardFill))
                .overlay(Capsule().strokeBorder(Color.fieldBorder, lineWidth: Outline.field))
        }
    }
}

/// Shows a date or time as plain text with an icon; the real system picker sits invisibly on top
/// so a tap still opens it (the compact picker's grey pill doesn't fit inside a field).
struct PickerFieldLabel<Picker: View>: View {
    let text: String
    let icon: String
    @ViewBuilder var picker: Picker

    var body: some View {
        HStack {
            Text(text)
                .font(.luckyBody)
                .foregroundStyle(Color.charcoal)
            Spacer()
            Image(systemName: icon)
                .foregroundStyle(Color.inkSecondary)
        }
        .overlay {
            picker
                .labelsHidden()
                .tint(Color.luckyBlue)
                .colorMultiply(.clear)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    FormField(title: "Date") {
        PickerFieldLabel(text: "29 Oct 2026", icon: "calendar") {
            DatePicker("Date", selection: .constant(.now), displayedComponents: .date)
        }
    }
    .padding()
}
