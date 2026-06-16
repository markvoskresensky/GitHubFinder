//
//  GitHubUser.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import Foundation

struct GitHubUser: Identifiable, Codable, Hashable {
    let id: Int
    let login: String
    let avatarURL: URL?
    let htmlURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }
}
