//
//  TestData.swift
//  GitHubFinderTests
//
//  Created by Marko on 15.06.2026.
//

import Foundation
@testable import GitHubFinder

enum TestData {
    static func user(id: Int = 1, login: String = "octocat") -> GitHubUser {
        GitHubUser(
            id: id,
            login: login,
            avatarURL: URL(string: "https://example.com/\(login).png"),
            htmlURL: URL(string: "https://github.com/\(login)")
        )
    }

    static func userDetail(
        id: Int = 1,
        login: String = "octocat",
        name: String? = "The Octocat",
        bio: String? = "Just a cat",
        publicRepos: Int = 8,
        followers: Int = 100,
        following: Int = 10
    ) -> UserDetail {
        UserDetail(
            id: id,
            login: login,
            name: name,
            bio: bio,
            avatarURL: URL(string: "https://example.com/\(login).png"),
            htmlURL: URL(string: "https://github.com/\(login)"),
            location: "Internet",
            company: "GitHub",
            blog: "https://github.blog",
            publicRepos: publicRepos,
            followers: followers,
            following: following
        )
    }

    static func repo(
        id: Int,
        name: String,
        stars: Int,
        language: String? = "Swift",
        fork: Bool = false
    ) -> Repository {
        Repository(
            id: id,
            name: name,
            fullName: "octocat/\(name)",
            description: "A repository named \(name)",
            stargazersCount: stars,
            language: language,
            htmlURL: URL(string: "https://github.com/octocat/\(name)"),
            fork: fork
        )
    }
}
