//
//  InputField.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 10/02/2026.
//

import SwiftUI

enum InputFieldType {
    case name
    case email
    case password
    case date
}

struct PasswordRequirements {
    let hasUppercase: Bool
    let hasNumber: Bool
    let hasMinLength: Bool
}

struct InputField: View {
    let placeholder: String
    let type: InputFieldType

    @Binding var text: String
    @Binding var date: Date?

    var isValid: Bool = true
    var passwordRequirements: PasswordRequirements? = nil

    @State private var showPassword = false
    @State private var showPasswordRequirements = false
    @FocusState private var isFocused: Bool

    // MARK: - Initializers

    // For text-based fields
    init(
        placeholder: String,
        type: InputFieldType,
        text: Binding<String>,
        isValid: Bool = true,
        passwordRequirements: PasswordRequirements? = nil
    ) {
        self.placeholder = placeholder
        self.type = type
        self._text = text
        self._date = .constant(nil)
        self.isValid = isValid
        self.passwordRequirements = passwordRequirements
    }

    // For date field
    init(
        placeholder: String,
        type: InputFieldType = .date,
        date: Binding<Date?>,
        isValid: Bool = true
    ) {
        self.placeholder = placeholder
        self.type = type
        self._text = .constant("")
        self._date = date
        self.isValid = isValid
        self.passwordRequirements = nil
    }

    private var promptText: Text {
        Text(placeholder).foregroundStyle(Color.placeholderGrey)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // MARK: - Field Types
            ZStack(alignment: .trailing) {
                switch type {

                case .date:
                    DatePicker(
                        placeholder,
                        selection: Binding(
                            get: { date ?? Date.now },
                            set: { date = $0 }
                        ),
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .tint(Color.luckyBlue)
                    .font(.luckyBodyStrong)
                    .fieldStyle(isFocused: false)

                case .password:
                    Group {
                        if showPassword {
                            TextField("", text: $text, prompt: promptText)
                        } else {
                            SecureField("", text: $text, prompt: promptText)
                        }
                    }
                    .fieldStyle(isFocused: isFocused)
                    .focused($isFocused)

                case .name, .email:
                    TextField("", text: $text, prompt: promptText)
                        .fieldStyle(isFocused: isFocused)
                        .textContentType(type == .email ? .emailAddress : .name)
                        .keyboardType(type == .email ? .emailAddress : .default)
                        .textInputAutocapitalization(type == .email ? .never : .words)
                        .focused($isFocused)
                }

                // MARK: - Trailing Icons
                if type == .password {
                    Button {
                        showPassword.toggle()
                    } label: {
                        Text(showPassword ? "Hide" : "Show")
                            .font(.luckySubheadlineStrong)
                            .foregroundStyle(Color.luckyBlue)
                            .padding(.trailing, 20)
                    }
                } else if (type == .name || type == .email), !text.isEmpty {
                    Image(systemName: "checkmark")
                        .foregroundStyle(isValid ? Color.luckyBlue : Color.clear)
                        .padding(.trailing, 20)
                        .symbolEffect(.bounce, value: isValid)
                }
            }

            // MARK: - Password Requirements
            if type == .password,
               showPasswordRequirements,
               let requirements = passwordRequirements {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Must contain at least:")
                        .font(.luckySubheadline)
                        .foregroundStyle(Color.charcoal)

                    PasswordRequirementRow(
                        text: "At least 1 uppercase",
                        isMet: requirements.hasUppercase
                    )

                    PasswordRequirementRow(
                        text: "At least 1 number",
                        isMet: requirements.hasNumber
                    )

                    PasswordRequirementRow(
                        text: "At least 8 characters",
                        isMet: requirements.hasMinLength
                    )
                }
                .padding(.horizontal, Spacing.s)
            }
        }
        .onChange(of: text) {
            guard type == .password else { return }

            if !text.isEmpty && !isValid {
                showPasswordRequirements = true
            } else if text.isEmpty {
                showPasswordRequirements = false
            }
        }
        .onChange(of: isValid) {
            guard type == .password, isValid else { return }

            // Small delay before hiding, so the last checkmark animation is visible
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    showPasswordRequirements = false
                }
            }
        }
    }
}

// MARK: - Password Requirement Row

struct PasswordRequirementRow: View {
    let text: String
    let isMet: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle" : "circle")
                .foregroundStyle(Color.luckyBlue)
                .font(.system(size: 15, weight: .bold))
                .frame(width: 16)
                .symbolEffect(.bounce, value: isMet)

            Text(text)
                .font(.luckySubheadline)
                .foregroundStyle(Color.inkSecondary)
        }
    }
}

// MARK: - Form Styling

extension View {
    func fieldStyle(isFocused: Bool) -> some View {
        self
            .font(.luckyBody)
            .foregroundStyle(Color.charcoal)
            .frame(height: 50)
            .padding(.horizontal, 20)
            .background(Capsule().fill(Color.cardFill))
            .overlay(
                Capsule()
                    .strokeBorder(
                        isFocused ? Color.luckyBlue : Color.fieldBorder,
                        lineWidth: Outline.field
                    )
            )
    }
}


// MARK: - Preview

#Preview("All Fields - Sign Up Form") {
    @Previewable @State var viewModel = AuthViewModel()
    @Previewable @State var birthDate: Date?

    VStack(spacing: 20) {
        InputField(
            placeholder: "Full Name",
            type: .name,
            text: $viewModel.name,
            isValid: viewModel.isNameValid
        )

        InputField(
            placeholder: "Email",
            type: .email,
            text: $viewModel.email,
            isValid: viewModel.isEmailValid
        )
        InputField(
            placeholder: "Birth Date",
            date: $birthDate
        )

        InputField(
            placeholder: "Password",
            type: .password,
            text: $viewModel.password,
            isValid: viewModel.isPasswordValid,
            passwordRequirements: PasswordRequirements(
                hasUppercase: viewModel.hasUppercase,
                hasNumber: viewModel.hasNumber,
                hasMinLength: viewModel.hasMinLength
            )
        )

    }
    .padding()
}
