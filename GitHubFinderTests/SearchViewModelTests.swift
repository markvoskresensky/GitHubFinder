//
//  SearchViewModelTests.swift
//  GitHubFinderTests
//
//  Created by Marko on 15.06.2026.
//

import Testing
import Foundation
@testable import GitHubFinder

@MainActor
@Suite("Search.ViewModel")
struct SearchViewModelTests {

    @Test("Начальное состояние — idle")
    func initialStateIsIdle() {
        let model = Search.ViewModel(service: MockGitHubService(), onSignOut: {})
        #expect(model.state.isIdle)
    }

    @Test("Пустой запрос не запускает поиск и оставляет idle")
    func emptyQueryDoesNotSearch() async throws {
        let service = MockGitHubService()
        let model = Search.ViewModel(service: service, onSignOut: {})

        model.query = "   "
        model.search()
        try await Task.sleep(for: .milliseconds(50))

        #expect(model.state.isIdle)
        #expect(service.searchUsersQueries.isEmpty)
    }

    @Test("Успешный поиск с результатами → loaded")
    func successfulSearchLoadsUsers() async throws {
        let service = MockGitHubService()
        service.searchUsersResult = .success(
            SearchUsersPage(
                users: [TestData.user(id: 1, login: "octocat"), TestData.user(id: 2, login: "hubot")],
                hasMore: false
            )
        )
        let model = Search.ViewModel(service: service, onSignOut: {})

        model.query = "oct"
        model.search()
        try await waitUntil { model.state.isLoaded }

        #expect(model.users.count == 2)
        #expect(model.users.first?.login == "octocat")
        #expect(service.searchUsersQueries == ["oct"])
        #expect(service.requestedPages == [1])
    }

    @Test("Поиск без результатов → empty")
    func emptyResultsGiveEmptyState() async throws {
        let service = MockGitHubService()
        service.searchUsersResult = .success(SearchUsersPage(users: [], hasMore: false))
        let model = Search.ViewModel(service: service, onSignOut: {})

        model.query = "zzzznotexist"
        model.search()
        try await waitUntil { model.state.isEmpty }

        #expect(model.state.isEmpty)
    }

    @Test("Ошибка сети → failed с человекочитаемым сообщением")
    func failureGivesFailedState() async throws {
        let service = MockGitHubService()
        service.searchUsersResult = .failure(GitHubError.rateLimited)
        let model = Search.ViewModel(service: service, onSignOut: {})

        model.query = "oct"
        model.search()
        try await waitUntil { model.state.failureMessage != nil }

        #expect(model.state.failureMessage == GitHubError.rateLimited.errorDescription)
    }

    @Test("Запрос обрезается от пробелов перед отправкой")
    func queryIsTrimmed() async throws {
        let service = MockGitHubService()
        service.searchUsersResult = .success(SearchUsersPage(users: [TestData.user()], hasMore: false))
        let model = Search.ViewModel(service: service, onSignOut: {})

        model.query = "   octocat   "
        model.search()
        try await waitUntil { model.state.isLoaded }

        #expect(service.searchUsersQueries == ["octocat"])
    }

    @Test("Догрузка следующей страницы добавляет пользователей")
    func loadMoreAppendsNextPage() async throws {
        let service = MockGitHubService()
        service.searchUsersHandler = { _, page in
            switch page {
            case 1:
                return .success(SearchUsersPage(users: [TestData.user(id: 1, login: "u1")], hasMore: true))
            default:
                return .success(SearchUsersPage(users: [TestData.user(id: 2, login: "u2")], hasMore: false))
            }
        }
        let model = Search.ViewModel(service: service, onSignOut: {})

        model.query = "oct"
        model.search()
        try await waitUntil { model.state.isLoaded }
        #expect(model.users.map(\.login) == ["u1"])

        model.loadMoreIfNeeded(currentItem: model.users[0])
        try await waitUntil { model.users.count == 2 }

        #expect(model.users.map(\.login) == ["u1", "u2"])
        #expect(service.requestedPages == [1, 2])
    }

    @Test("Догрузки нет, когда страниц больше нет")
    func doesNotLoadMoreWhenNoMorePages() async throws {
        let service = MockGitHubService()
        service.searchUsersResult = .success(SearchUsersPage(users: [TestData.user(id: 1, login: "u1")], hasMore: false))
        let model = Search.ViewModel(service: service, onSignOut: {})

        model.query = "oct"
        model.search()
        try await waitUntil { model.state.isLoaded }

        model.loadMoreIfNeeded(currentItem: model.users[0])
        try await Task.sleep(for: .milliseconds(50))

        #expect(service.requestedPages == [1])
    }

    @Test("401 при поиске → onSignOut")
    func unauthorizedTriggersSignOut() async throws {
        let service = MockGitHubService()
        service.searchUsersResult = .failure(GitHubError.unauthorized)
        var didSignOut = false
        let model = Search.ViewModel(service: service, onSignOut: { didSignOut = true })

        model.query = "oct"
        model.search()
        try await waitUntil { didSignOut }

        #expect(didSignOut)
    }
}
