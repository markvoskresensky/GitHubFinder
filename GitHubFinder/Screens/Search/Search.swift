//
//  Search.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import SwiftUI

enum Search {}

extension Search {
    static func view(onSignOut: @escaping () -> Void) -> some View {
        let viewModel = Search.ViewModel(service: GitHubService(), onSignOut: onSignOut)
        return Search.Screen(model: viewModel)
    }
}
