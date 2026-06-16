//
//  Profile.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import SwiftUI

enum Profile {}

extension Profile {
    static func view(login: String, onUnauthorized: @escaping () -> Void) -> some View {
        let model = ViewModel(
            login: login,
            service: GitHubService(tokenStore: TokenStore()),
            onUnauthorized: onUnauthorized
        )
        return Profile.Screen(model: model)
    }
}
