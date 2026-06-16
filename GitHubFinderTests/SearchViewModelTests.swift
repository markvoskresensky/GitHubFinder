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
        service.searchUsersResult = .success([
            TestData.user(id: 1, login: "octocat"),
            TestData.user(id: 2, login: "hubot")
        ])
        let model = Search.ViewModel(service: service, onSignOut: {})

        model.query = "oct"
        model.search()
        try await waitUntil { model.state.users != nil }

        #expect(model.state.users?.count == 2)
        #expect(model.state.users?.first?.login == "octocat")
        #expect(service.searchUsersQueries == ["oct"])
    }

    @Test("Поиск без результатов → empty")
    func emptyResultsGiveEmptyState() async throws {
        let service = MockGitHubService()
        service.searchUsersResult = .success([])
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
        service.searchUsersResult = .success([TestData.user()])
        let model = Search.ViewModel(service: service, onSignOut: {})

        model.query = "   octocat   "
        model.search()
        try await waitUntil { model.state.users != nil }

        #expect(service.searchUsersQueries == ["octocat"])
    }
}
