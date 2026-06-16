//
//  GitHubService.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import Foundation

protocol GitHubServicing: Sendable {
    func searchUsers(query: String) async throws -> [GitHubUser]
    func user(login: String) async throws -> UserDetail
    func repositories(login: String) async throws -> [Repository]
}

enum GitHubError: LocalizedError {
    case network
    case rateLimited
    case notFound
    case http(Int)
    case decoding

    var errorDescription: String? {
        switch self {
        case .network:
            return String(localized: "Couldn't reach GitHub. Check your internet connection.")
        case .rateLimited:
            return String(localized: "GitHub rate limit exceeded. Try again later.")
        case .notFound:
            return String(localized: "User not found.")
        case .http(let code):
            return String(localized: "GitHub server error (code \(code)).")
        case .decoding:
            return String(localized: "Couldn't process the server response.")
        }
    }
}

struct GitHubService: GitHubServicing {
    private let session: URLSession
    private let baseURL = URL(string: "https://api.github.com")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchUsers(query: String) async throws -> [GitHubUser] {
        var components = URLComponents(url: baseURL.appendingPathComponent("search/users"),
                                       resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "per_page", value: "30")
        ]
        guard let url = components.url else { throw GitHubError.network }
        let response: SearchUsersResponse = try await get(url)
        return response.items
    }

    func user(login: String) async throws -> UserDetail {
        let url = baseURL.appendingPathComponent("users/\(login)")
        return try await get(url)
    }

    func repositories(login: String) async throws -> [Repository] {
        var components = URLComponents(url: baseURL.appendingPathComponent("users/\(login)/repos"),
                                       resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "sort", value: "updated"),
            URLQueryItem(name: "per_page", value: "100")
        ]
        guard let url = components.url else { throw GitHubError.network }
        return try await get(url)
    }
}

private extension GitHubService {
    struct SearchUsersResponse: Decodable {
        let items: [GitHubUser]
    }

    func get<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw GitHubError.network
        }

        guard let http = response as? HTTPURLResponse else { throw GitHubError.network }

        switch http.statusCode {
        case 200...299:
            break
        case 403, 429:
            throw GitHubError.rateLimited
        case 404:
            throw GitHubError.notFound
        default:
            throw GitHubError.http(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw GitHubError.decoding
        }
    }
}
