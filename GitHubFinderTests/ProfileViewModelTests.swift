//
//  ProfileViewModelTests.swift
//  GitHubFinderTests
//
//  Created by Marko on 15.06.2026.
//

import Testing
import Foundation
@testable import GitHubFinder

@MainActor
@Suite("Profile.ViewModel")
struct ProfileViewModelTests {

    @Test("Успешная загрузка → loaded с профилем и репозиториями")
    func loadsProfileAndRepositories() async {
        let service = MockGitHubService()
        service.userResult = .success(TestData.userDetail(login: "octocat", followers: 42))
        service.repositoriesResult = .success(
            RepositoriesPage(repos: [TestData.repo(id: 1, name: "Hello", stars: 3)], hasMore: false)
        )
        let model = Profile.ViewModel(login: "octocat", service: service)

        await model.load()

        #expect(model.state.isLoaded)
        #expect(model.user?.login == "octocat")
        #expect(model.user?.followers == 42)
        #expect(model.repositories.count == 1)
        #expect(service.requestedUserLogins == ["octocat"])
        #expect(service.requestedRepoLogins == ["octocat"])
        #expect(service.requestedRepoPages == [1])
    }

    @Test("Порядок репозиториев сохраняется как с сервера")
    func keepsServerOrder() async {
        let service = MockGitHubService()
        service.repositoriesResult = .success(
            RepositoriesPage(
                repos: [
                    TestData.repo(id: 1, name: "first", stars: 5),
                    TestData.repo(id: 2, name: "second", stars: 999),
                    TestData.repo(id: 3, name: "third", stars: 50)
                ],
                hasMore: false
            )
        )
        let model = Profile.ViewModel(login: "octocat", service: service)

        await model.load()

        #expect(model.repositories.map(\.name) == ["first", "second", "third"])
    }

    @Test("Догрузка следующей страницы добавляет репозитории")
    func loadMoreAppendsNextPage() async throws {
        let service = MockGitHubService()
        service.repositoriesHandler = { _, page in
            switch page {
            case 1:
                return .success(RepositoriesPage(repos: [TestData.repo(id: 1, name: "r1", stars: 1)], hasMore: true))
            default:
                return .success(RepositoriesPage(repos: [TestData.repo(id: 2, name: "r2", stars: 2)], hasMore: false))
            }
        }
        let model = Profile.ViewModel(login: "octocat", service: service)

        await model.load()
        #expect(model.repositories.map(\.name) == ["r1"])

        model.loadMoreIfNeeded(currentItem: model.repositories[0])
        try await waitUntil { model.repositories.count == 2 }

        #expect(model.repositories.map(\.name) == ["r1", "r2"])
        #expect(service.requestedRepoPages == [1, 2])
    }

    @Test("Догрузки нет, когда страниц больше нет")
    func doesNotLoadMoreWhenNoMorePages() async throws {
        let service = MockGitHubService()
        service.repositoriesResult = .success(
            RepositoriesPage(repos: [TestData.repo(id: 1, name: "r1", stars: 1)], hasMore: false)
        )
        let model = Profile.ViewModel(login: "octocat", service: service)

        await model.load()
        model.loadMoreIfNeeded(currentItem: model.repositories[0])
        try await Task.sleep(for: .milliseconds(50))

        #expect(service.requestedRepoPages == [1])
    }

    @Test("Ошибка загрузки → failed с человекочитаемым сообщением")
    func failureGivesFailedState() async {
        let service = MockGitHubService()
        service.userResult = .failure(GitHubError.notFound)
        let model = Profile.ViewModel(login: "ghost", service: service)

        await model.load()

        #expect(model.state.failureMessage == GitHubError.notFound.errorDescription)
    }

    @Test("login прокидывается в сервис")
    func passesLoginToService() async {
        let service = MockGitHubService()
        let model = Profile.ViewModel(login: "torvalds", service: service)

        await model.load()

        #expect(model.login == "torvalds")
        #expect(service.requestedUserLogins == ["torvalds"])
    }
}
