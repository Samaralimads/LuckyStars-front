//
//  AuthService.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 18/05/2026.
//

import Foundation

struct AuthService {

    // MARK: - Request Models
    struct RegisterRequest: Encodable {
        let firstName: String
        let birthDate: String
        let email: String
        let password: String
    }

    struct LoginRequest: Encodable {
        let email: String
        let password: String
    }

    struct ForgotPasswordRequest: Encodable {
        let email: String
    }

    struct VerifyCodeRequest: Encodable {
        let email: String
        let code: String
    }

    struct ResetPasswordRequest: Encodable {
        let email: String
        let code: String
        let newPassword: String
    }

    // MARK: - Response Models
    struct AuthResponse: Decodable {
        let token: String
        let user: User
    }

    // MARK: - Register
    static func register(firstName: String, birthDate: String, email: String, password: String) async throws -> AuthResponse {
        let body = RegisterRequest(firstName: firstName, birthDate: birthDate, email: email, password: password)
        let response: AuthResponse = try await APIClient.shared.request("/users/register", method: "POST", body: body, requiresAuth: false)
        guard JWTService.save(token: response.token) else { throw SessionError.couldNotSaveToken }
        return response
    }

    // MARK: - Login
    static func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await APIClient.shared.request("/users/login", method: "POST", body: body, requiresAuth: false)
        guard JWTService.save(token: response.token) else { throw SessionError.couldNotSaveToken }
        return response
    }

    // MARK: - Sign in with Apple
    struct AppleSignInRequest: Encodable {
        let identityToken: String
        let nonce: String
        let authorizationCode: String?
        let firstName: String?
        let birthDate: String?
    }

    struct AppleAuthResponse: Decodable {
        /// nil while `needsProfile` is true.
        let token: String?
        let user: User?
        /// A first-time Apple user: ask for the name (if Apple didn't give it) and the birth date, then send again.
        let needsProfile: Bool
        let isNewUser: Bool
    }

    static func signInWithApple(_ body: AppleSignInRequest) async throws -> AppleAuthResponse {
        let response: AppleAuthResponse = try await APIClient.shared.request("/auth/apple", method: "POST", body: body, requiresAuth: false)
        if let token = response.token {
            guard JWTService.save(token: token) else { throw SessionError.couldNotSaveToken }
        }
        return response
    }

    // MARK: - Logout
    static func logout() {
        JWTService.delete()
    }

    // MARK: - Forgot Password
    static func forgotPassword(email: String) async throws {
        let body = ForgotPasswordRequest(email: email)
        try await APIClient.shared.requestEmpty("/auth/forgot-password", method: "POST", body: body, requiresAuth: false)
    }

    // MARK: - Verify Code
    static func verifyCode(email: String, code: String) async throws {
        let body = VerifyCodeRequest(email: email, code: code)
        try await APIClient.shared.requestEmpty("/auth/verify-code", method: "POST", body: body, requiresAuth: false)
    }

    // MARK: - Reset Password
    static func resetPassword(email: String, code: String, newPassword: String) async throws {
        let body = ResetPasswordRequest(email: email, code: code, newPassword: newPassword)
        try await APIClient.shared.requestEmpty("/auth/reset-password", method: "POST", body: body, requiresAuth: false)
    }
}
