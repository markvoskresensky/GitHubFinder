//
//  MockGitHubService.swift
//  GitHubFinderTests
//
//  Created by Marko on 15.06.2026.
//

import Foundation
@testable import GitHubFinder

final class MockGitHubService: GitHubServicing, @unchecked Sendable {
    var searchUsersResult: Result<SearchUsersPage, Error> = .success(SearchUsersPage(users: [], hasMore: false))
    var searchUsersHandler: (@Sendable (String, Int) -> Result<SearchUsersPage, Error>)?
    var userResult: Result<UserDetail, Error> = .success(TestData.userDetail())
    var repositoriesResult: Result<RepositoriesPage, Error> = .success(RepositoriesPage(repos: [], hasMore: false))
    var repositoriesHandler: (@Sendable (String, Int) -> Result<RepositoriesPage, Error>)?

    private(set) var searchUsersQueries: [String] = []
    private(set) var requestedPages: [Int] = []
    private(set) var requestedUserLogins: [String] = []
    private(set) var requestedRepoLogins: [String] = []
    private(set) var requestedRepoPages: [Int] = []

    func searchUsers(query: String, page: Int) async throws -> SearchUsersPage {
        searchUsersQueries.append(query)
        requestedPages.append(page)
        if let handler = searchUsersHandler {
            return try handler(query, page).get()
        }
        return try searchUsersResult.get()
    }

    func user(login: String) async throws -> UserDetail {
        requestedUserLogins.append(login)
        return try userResult.get()
    }

    func repositories(login: String, page: Int) async throws -> RepositoriesPage {
        requestedRepoLogins.append(login)
        requestedRepoPages.append(page)
        if let handler = repositoriesHandler {
            return try handler(login, page).get()
        }
        return try repositoriesResult.get()
    }
}
