//
//  UserDetail.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import Foundation

struct UserDetail: Identifiable, Codable, Hashable {
    let id: Int
    let login: String
    let name: String?
    let bio: String?
    let avatarURL: URL?
    let htmlURL: URL?
    let location: String?
    let company: String?
    let blog: String?
    let publicRepos: Int
    let followers: Int
    let following: Int

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case name
        case bio
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
        case location
        case company
        case blog
        case publicRepos = "public_repos"
        case followers
        case following
    }
}
