//
//  JWTService.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 18/05/2026.
//

import Foundation
import Security

enum SessionError: Error, LocalizedError {
    case couldNotSaveToken

    var errorDescription: String? {
        "We couldn't securely save your session on this device. Please try again."
    }
}

struct JWTService {
    private static let tokenKey = "luckystars.jwt.token"

    // MARK: - Save
    @discardableResult
    static func save(token: String) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }

        delete()

        let query: [String: Any] = [
            kSecClass as String:          kSecClassGenericPassword,
            kSecAttrAccount as String:    tokenKey,
            kSecValueData as String:      data,
            // Readable after the first unlock (so background work still works), never copied to another device.
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    // MARK: - Get
    static func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        return token
    }

    // MARK: - Expiry
    /// True when the stored token exists and its `exp` claim hasn't passed.
    /// A token we can't read the expiry from is treated as valid; the server has the final say (401).
    static func hasUsableToken() -> Bool {
        guard let token = getToken() else { return false }
        guard let expiry = expiryDate(of: token) else { return true }
        return expiry > .now
    }

    private static func expiryDate(of token: String) -> Date? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }

        // JWT segments are base64url without padding.
        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval
        else { return nil }

        return Date(timeIntervalSince1970: exp)
    }

    // MARK: - Delete
    static func delete() {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        SecItemDelete(query as CFDictionary)
    }
}
