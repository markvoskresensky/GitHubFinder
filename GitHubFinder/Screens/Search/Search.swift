//
//  Search.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import SwiftUI

enum Search {}

extension Search {
    static func view() -> some View {
        let viewModel = Search.ViewModel(service: GitHubService())
        return Search.Screen(model: viewModel)
    }
}
