//
//  AuthViewModel.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 10/02/2026.
//

import Foundation

@Observable
class AuthViewModel {
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var birthDate: Date? = nil

    var isLoading: Bool = false
    var errorMessage: String? = nil

    var hasUppercase: Bool {
        password.range(of: "[A-Z]", options: .regularExpression) != nil
    }

    var hasNumber: Bool {
        password.range(of: "[0-9]", options: .regularExpression) != nil
    }

    var hasMinLength: Bool {
        password.count >= 8
    }

    var isPasswordValid: Bool {
        hasUppercase && hasNumber && hasMinLength
    }

    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    var isNameValid: Bool {
        name.count >= 2
    }

    static let minimumAge = 13

    /// The latest birth date that still meets the minimum age.
    static var latestBirthDate: Date {
        Calendar.current.date(byAdding: .year, value: -minimumAge, to: .now) ?? .now
    }

    var isBirthDateValid: Bool {
        guard let birthDate else { return false }
        return birthDate <= Self.latestBirthDate
    }

    var canSignUp: Bool {
        isNameValid && isEmailValid && isPasswordValid && isBirthDateValid && !isLoading
    }

    var canSignIn: Bool {
        isEmailValid && !password.isEmpty && !isLoading
    }

    // MARK: - Sign Up
    func signUp(appState: AppState) async {
        guard canSignUp, let birthDate else { return }
        isLoading = true
        errorMessage = nil

        let birthDateString = APIDate.dayString(from: birthDate)

        do {
            _ = try await AuthService.register(
                firstName: name,
                birthDate: birthDateString,
                email: email,
                password: password
            )
            appState.register()
        } catch let error as APIError {
            print("Sign up error: \(error)")
            switch error {
            case .serverError(409, _):
                errorMessage = "An account with this email already exists."
            default:
                errorMessage = "Something went wrong. Please try again."
            }
        } catch {
            print("Sign up error: \(error)")
            errorMessage = "Something went wrong. Please try again."
        }

        isLoading = false
    }

    // MARK: - Sign In
    func signIn(appState: AppState) async {
        guard canSignIn else { return }
        isLoading = true
        errorMessage = nil

        do {
            _ = try await AuthService.login(email: email, password: password)
            appState.login()
        } catch let error as APIError {
            print("Sign in error: \(error)")
            switch error {
            case .serverError(401, _):
                errorMessage = "Incorrect email or password."
            default:
                errorMessage = "Something went wrong. Please try again."
            }
        } catch {
            print("Sign in error: \(error)")
            errorMessage = "Something went wrong. Please try again."
        }

        isLoading = false
    }
}
