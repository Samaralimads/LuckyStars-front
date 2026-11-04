//
//  APIClient.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 18/05/2026.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case decodingError(Error)
    case serverError(Int, String)
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:              return "Invalid URL."
        case .decodingError(let e):    return "Failed to decode response: \(e.localizedDescription)"
        case .serverError(_, let msg): return msg
        case .unauthorized:            return "Session expired. Please log in again."
        case .unknown(let e):          return e.localizedDescription
        }
    }
}

extension Error {
    /// True when a request was cancelled (view left the screen, refresh superseded, ...).
    /// That is not a failure to show to the user.
    var isCancellation: Bool {
        self is CancellationError || (self as? URLError)?.code == .cancelled
    }
}

struct APIErrorResponse: Decodable {
    let reason: String
}

extension Notification.Name {
    static let sessionExpired = Notification.Name("luckystars.sessionExpired")
}

final class APIClient {
    static let shared = APIClient()
    private let baseURL: String = {
        #if DEBUG
        return "http://127.0.0.1:8080"
        #else
        // TODO: set the production HTTPS URL before release.
        return "https://REPLACE-WITH-PRODUCTION-URL"
        #endif
    }()

    private init() {}

    // MARK: - Request with response body
    func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        queryItems: [URLQueryItem] = [],
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        let request = try makeRequest(path, method: method, queryItems: queryItems, body: body, requiresAuth: requiresAuth)
        let data = try await perform(request, requiresAuth: requiresAuth)

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Request with no response body
    func requestEmpty(
        _ path: String,
        method: String = "DELETE",
        queryItems: [URLQueryItem] = [],
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws {
        let request = try makeRequest(path, method: method, queryItems: queryItems, body: body, requiresAuth: requiresAuth)
        _ = try await perform(request, requiresAuth: requiresAuth)
    }

    // MARK: - Helpers
    private func makeRequest(
        _ path: String,
        method: String,
        queryItems: [URLQueryItem],
        body: Encodable?,
        requiresAuth: Bool
    ) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            guard let token = JWTService.getToken() else {
                // The token is gone (e.g. removed from the Keychain): same as an expired session.
                NotificationCenter.default.post(name: .sessionExpired, object: nil)
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        return request
    }

    private func perform(_ request: URLRequest, requiresAuth: Bool) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(URLError(.badServerResponse))
        }

        // Only treat a 401 as a session-expiry (and force a global logout) when
        // the request actually carried a token. A 401 on an unauthenticated
        // request (e.g. login with the wrong password) is a normal credentials
        // error and falls through to the generic serverError case below.
        if requiresAuth && httpResponse.statusCode == 401 {
            NotificationCenter.default.post(name: .sessionExpired, object: nil)
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw APIError.serverError(httpResponse.statusCode, errorResponse?.reason ?? "Something went wrong.")
        }

        return data
    }
}
