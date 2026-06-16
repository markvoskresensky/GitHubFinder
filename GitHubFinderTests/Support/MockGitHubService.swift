//
//  MockGitHubService.swift
//  GitHubFinderTests
//
//  Created by Marko on 15.06.2026.
//

import Foundation
@testable import GitHubFinder

final class MockGitHubService: GitHubServicing, @unchecked Sendable {
    var searchUsersResult: Result<[GitHubUser], Error> = .success([])
    var userResult: Result<UserDetail, Error> = .success(TestData.userDetail())
    var repositoriesResult: Result<[Repository], Error> = .success([])

    private(set) var searchUsersQueries: [String] = []
    private(set) var requestedUserLogins: [String] = []
    private(set) var requestedRepoLogins: [String] = []

    func searchUsers(query: String) async throws -> [GitHubUser] {
        searchUsersQueries.append(query)
        return try searchUsersResult.get()
    }

    func user(login: String) async throws -> UserDetail {
        requestedUserLogins.append(login)
        return try userResult.get()
    }

    func repositories(login: String) async throws -> [Repository] {
        requestedRepoLogins.append(login)
        return try repositoriesResult.get()
    }
}
