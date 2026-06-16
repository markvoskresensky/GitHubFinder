//
//  Repository.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import Foundation

struct Repository: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let stargazersCount: Int
    let language: String?
    let htmlURL: URL?
    let fork: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case description
        case stargazersCount = "stargazers_count"
        case language
        case htmlURL = "html_url"
        case fork
    }
}
