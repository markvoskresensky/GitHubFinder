//
//  GitHubServiceTests.swift
//  GitHubFinderTests
//
//  Created by Marko on 16.06.2026.
//

import Testing
import Foundation
@testable import GitHubFinder

@Suite("GitHubService", .serialized)
struct GitHubServiceTests {

    @Test("Добавляет заголовок Authorization, когда есть токен")
    func setsAuthorizationHeaderWhenTokenPresent() async throws {
        let store = MockTokenStore()
        store.save("gho_secret")
        MockURLProtocol.requestHandler = { _ in (httpResponse(status: 200), Data(#"{"items":[]}"#.utf8)) }
        let service = GitHubService(session: .stubbed(), tokenStore: store)

        _ = try await service.searchUsers(query: "octocat")

        #expect(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer gho_secret")
    }

    @Test("Без токена заголовок Authorization не ставится")
    func omitsAuthorizationHeaderWithoutToken() async throws {
        MockURLProtocol.requestHandler = { _ in (httpResponse(status: 200), Data(#"{"items":[]}"#.utf8)) }
        let service = GitHubService(session: .stubbed(), tokenStore: MockTokenStore())

        _ = try await service.searchUsers(query: "octocat")

        #expect(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test("searchUsers парсит результаты")
    func searchUsersParsesItems() async throws {
        let json = #"{"items":[{"id":1,"login":"octocat","avatar_url":"https://example.com/a.png","html_url":"https://github.com/octocat"}]}"#
        MockURLProtocol.requestHandler = { _ in (httpResponse(status: 200), Data(json.utf8)) }
        let service = GitHubService(session: .stubbed(), tokenStore: MockTokenStore())

        let users = try await service.searchUsers(query: "oct")

        #expect(users.map(\.login) == ["octocat"])
    }

    @Test("user парсит профиль")
    func userParsesProfile() async throws {
        let json = #"{"id":1,"login":"octocat","public_repos":5,"followers":10,"following":2}"#
        MockURLProtocol.requestHandler = { _ in (httpResponse(status: 200), Data(json.utf8)) }
        let service = GitHubService(session: .stubbed(), tokenStore: MockTokenStore())

        let user = try await service.user(login: "octocat")

        #expect(user.login == "octocat")
        #expect(user.publicRepos == 5)
    }

    @Test("403 → rateLimited")
    func rateLimitedOn403() async throws {
        MockURLProtocol.requestHandler = { _ in (httpResponse(status: 403), Data()) }
        let service = GitHubService(session: .stubbed(), tokenStore: MockTokenStore())

        await #expect(throws: GitHubError.rateLimited) {
            _ = try await service.user(login: "octocat")
        }
    }

    @Test("404 → notFound")
    func notFoundOn404() async throws {
        MockURLProtocol.requestHandler = { _ in (httpResponse(status: 404), Data()) }
        let service = GitHubService(session: .stubbed(), tokenStore: MockTokenStore())

        await #expect(throws: GitHubError.notFound) {
            _ = try await service.user(login: "ghost")
        }
    }
}
