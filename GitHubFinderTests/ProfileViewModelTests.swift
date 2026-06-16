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
        service.repositoriesResult = .success([TestData.repo(id: 1, name: "Hello", stars: 3)])
        let model = Profile.ViewModel(login: "octocat", service: service)

        await model.load()

        #expect(model.state.isLoaded)
        #expect(model.user?.login == "octocat")
        #expect(model.user?.followers == 42)
        #expect(model.repositories.count == 1)
        #expect(service.requestedUserLogins == ["octocat"])
        #expect(service.requestedRepoLogins == ["octocat"])
    }

    @Test("Репозитории сортируются: не-форки сначала, затем по убыванию звёзд")
    func repositoriesAreSorted() async {
        let service = MockGitHubService()
        service.repositoriesResult = .success([
            TestData.repo(id: 1, name: "low", stars: 5),
            TestData.repo(id: 2, name: "popularFork", stars: 999, fork: true),
            TestData.repo(id: 3, name: "high", stars: 50)
        ])
        let model = Profile.ViewModel(login: "octocat", service: service)

        await model.load()

        #expect(model.repositories.map(\.name) == ["high", "low", "popularFork"])
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
