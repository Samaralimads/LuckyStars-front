//
//  AppleSignInViewModel.swift
//  LuckyStars
//
//  The Sign in with Apple flow:
//   1. The Apple button asks Apple for the user's identity (we send a nonce along).
//   2. We send Apple's answer to our backend.
//   3. A new person has no birth date yet (Apple doesn't give one): the backend answers `needsProfile`,
//      the app asks for it, and sends the same Apple answer again with it.
//

import AuthenticationServices
import CryptoKit
import Foundation
import Security

/// What Apple gave us for one sign-in, kept while the user fills in the missing profile details.
struct AppleCredentialInfo {
    let identityToken: String
    let nonce: String
    let authorizationCode: String?
    /// Apple shares the name only the first time, and only if the user allows it.
    let firstName: String?
}

@Observable
class AppleSignInViewModel {
    var isLoading = false
    var errorMessage: String? = nil
    /// Set when the backend needs more details to create the account; shows the "finish your profile" sheet.
    var pendingProfile: AppleCredentialInfo? = nil

    private var rawNonce = ""

    // MARK: - Step 1: the request to Apple
    func configure(_ request: ASAuthorizationAppleIDRequest) {
        rawNonce = Self.makeNonce()
        request.requestedScopes = [.fullName, .email]
        // Apple puts this hash in the identity token; the backend checks it against `rawNonce`.
        request.nonce = Self.sha256(rawNonce)
        errorMessage = nil
    }

    // MARK: - Step 2: Apple's answer
    func handle(_ result: Result<ASAuthorization, any Error>, appState: AppState) async {
        switch result {
        case .failure(let error):
            // The user closing the Apple sheet is not an error.
            if (error as? ASAuthorizationError)?.code == .canceled { return }
            print("Apple sign-in error: \(error)")
            errorMessage = "Sign in with Apple didn't work. Please try again."

        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let identityToken = String(data: tokenData, encoding: .utf8)
            else {
                errorMessage = "Sign in with Apple didn't work. Please try again."
                return
            }

            let info = AppleCredentialInfo(
                identityToken: identityToken,
                nonce: rawNonce,
                authorizationCode: credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) },
                firstName: credential.fullName?.givenName
            )
            await send(info, firstName: info.firstName, birthDate: nil, appState: appState)
        }
    }

    // MARK: - Step 3: our backend
    /// Returns nil on success (or when more details are needed), or the message to show.
    @discardableResult
    func send(_ info: AppleCredentialInfo, firstName: String?, birthDate: Date?, appState: AppState) async -> String? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let body = AuthService.AppleSignInRequest(
            identityToken: info.identityToken,
            nonce: info.nonce,
            authorizationCode: info.authorizationCode,
            firstName: firstName,
            birthDate: birthDate.map { APIDate.dayString(from: $0) }
        )

        do {
            let response = try await AuthService.signInWithApple(body)

            if response.needsProfile {
                pendingProfile = info
                return nil
            }

            pendingProfile = nil
            // A brand-new account goes through onboarding (pairing); an existing one goes straight in.
            if response.isNewUser {
                appState.register()
            } else {
                appState.login()
            }
            return nil
        } catch let error as APIError {
            print("Apple sign-in backend error: \(error)")
            if case .serverError(401, _) = error {
                // The identity token is only valid for a few minutes.
                pendingProfile = nil
            }
            let message = error.errorDescription ?? "Sign in with Apple didn't work. Please try again."
            errorMessage = message
            return message
        } catch {
            print("Apple sign-in backend error: \(error)")
            let message = "Sign in with Apple didn't work. Please try again."
            errorMessage = message
            return message
        }
    }

    // MARK: - Nonce
    private static func makeNonce() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status != errSecSuccess {
            // Practically never; a UUID is still unguessable.
            return UUID().uuidString + UUID().uuidString
        }
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    private static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
