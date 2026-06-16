//
//  GitHubService.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import Foundation

struct SearchUsersPage: Sendable {
    let users: [GitHubUser]
    let hasMore: Bool
}

struct RepositoriesPage: Sendable {
    let repos: [Repository]
    let hasMore: Bool
}

protocol GitHubServicing: Sendable {
    func searchUsers(query: String, page: Int) async throws -> SearchUsersPage
    func user(login: String) async throws -> UserDetail
    func repositories(login: String, page: Int) async throws -> RepositoriesPage
}

enum GitHubError: LocalizedError, Equatable {
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
    private let tokenStore: TokenStoring
    private let baseURL = URL(string: "https://api.github.com")!
    private let perPage = 30
    private let maxSearchResults = 1000

    init(session: URLSession = .shared, tokenStore: TokenStoring) {
        self.session = session
        self.tokenStore = tokenStore
    }

    func searchUsers(query: String, page: Int) async throws -> SearchUsersPage {
        var components = URLComponents(url: baseURL.appendingPathComponent("search/users"),
                                       resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        guard let url = components.url else { throw GitHubError.network }
        let response: SearchUsersResponse = try await get(url)
        let available = min(response.totalCount, maxSearchResults)
        let hasMore = page * perPage < available
        return SearchUsersPage(users: response.items, hasMore: hasMore)
    }

    func user(login: String) async throws -> UserDetail {
        let url = baseURL.appendingPathComponent("users/\(login)")
        return try await get(url)
    }

    func repositories(login: String, page: Int) async throws -> RepositoriesPage {
        var components = URLComponents(url: baseURL.appendingPathComponent("users/\(login)/repos"),
                                       resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "sort", value: "updated"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        guard let url = components.url else { throw GitHubError.network }
        let repos: [Repository] = try await get(url)
        return RepositoriesPage(repos: repos, hasMore: repos.count == perPage)
    }
}

private extension GitHubService {
    struct SearchUsersResponse: Decodable {
        let totalCount: Int
        let items: [GitHubUser]

        enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case items
        }
    }

    func get<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        if let token = tokenStore.read() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

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
