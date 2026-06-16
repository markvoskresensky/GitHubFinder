//
//  GitHubAuthService.swift
//  GitHubFinder
//
//  Created by Marko on 16.06.2026.
//

import Foundation

struct DeviceCodeResponse: Decodable, Sendable {
    let deviceCode: String
    let userCode: String
    let verificationURI: URL
    let expiresIn: Int
    let interval: Int

    enum CodingKeys: String, CodingKey {
        case deviceCode = "device_code"
        case userCode = "user_code"
        case verificationURI = "verification_uri"
        case expiresIn = "expires_in"
        case interval
    }
}

enum GitHubAuthError: LocalizedError {
    case network
    case deviceFlowDisabled
    case accessDenied
    case expiredToken
    case unexpected(String)

    var errorDescription: String? {
        switch self {
        case .network:
            return String(localized: "Couldn't reach GitHub. Check your internet connection.")
        case .deviceFlowDisabled:
            return String(localized: "Device Flow is disabled for this OAuth app.")
        case .accessDenied:
            return String(localized: "Authorization was cancelled.")
        case .expiredToken:
            return String(localized: "The code expired. Please try again.")
        case .unexpected(let message):
            return message
        }
    }
}

protocol GitHubAuthorizing: Sendable {
    func requestDeviceCode() async throws -> DeviceCodeResponse
    func pollForAccessToken(deviceCode: String, interval: Int) async throws -> String
}

struct GitHubAuthService: GitHubAuthorizing {
    private let clientID = "Ov23liL1iehzI0Akt9bc"
    private let scope = "read:user"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func requestDeviceCode() async throws -> DeviceCodeResponse {
        let url = URL(string: "https://github.com/login/device/code")!
        let data = try await post(url, fields: ["client_id": clientID, "scope": scope])

        if let device = try? JSONDecoder().decode(DeviceCodeResponse.self, from: data) {
            return device
        }
        throw error(from: data)
    }

    func pollForAccessToken(deviceCode: String, interval: Int) async throws -> String {
        let url = URL(string: "https://github.com/login/oauth/access_token")!
        var delay = interval

        while true {
            try await Task.sleep(for: .seconds(delay))
            try Task.checkCancellation()

            let data = try await post(url, fields: [
                "client_id": clientID,
                "device_code": deviceCode,
                "grant_type": "urn:ietf:params:oauth:grant-type:device_code"
            ])

            if let token = (try? JSONDecoder().decode(AccessTokenResponse.self, from: data))?.accessToken {
                return token
            }

            switch (try? JSONDecoder().decode(AuthErrorResponse.self, from: data))?.error {
            case "authorization_pending":
                continue
            case "slow_down":
                delay += 5
            case "access_denied":
                throw GitHubAuthError.accessDenied
            case "expired_token":
                throw GitHubAuthError.expiredToken
            case "device_flow_disabled":
                throw GitHubAuthError.deviceFlowDisabled
            case let other:
                throw GitHubAuthError.unexpected(other ?? "unknown")
            }
        }
    }
}

private extension GitHubAuthService {
    struct AccessTokenResponse: Decodable {
        let accessToken: String?

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }

    struct AuthErrorResponse: Decodable {
        let error: String
    }

    func post(_ url: URL, fields: [String: String]) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = encode(fields).data(using: .utf8)

        do {
            let (data, _) = try await session.data(for: request)
            return data
        } catch {
            throw GitHubAuthError.network
        }
    }

    func encode(_ fields: [String: String]) -> String {
        var components = URLComponents()
        components.queryItems = fields.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components.percentEncodedQuery ?? ""
    }

    func error(from data: Data) -> GitHubAuthError {
        switch (try? JSONDecoder().decode(AuthErrorResponse.self, from: data))?.error {
        case "device_flow_disabled":
            return .deviceFlowDisabled
        case let other?:
            return .unexpected(other)
        case nil:
            return .network
        }
    }
}
