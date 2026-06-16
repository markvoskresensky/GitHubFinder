//
//  Authorization.swift
//  GitHubFinder
//
//  Created by Marko on 16.06.2026.
//

import SwiftUI

enum Authorization {}

extension Authorization {
    static func view(onAuthorized: @escaping () -> Void) -> some View {
        let model = ViewModel(service: GitHubAuthService(), tokenStore: TokenStore(), onAuthorized: onAuthorized)
        return Authorization.Screen(model: model)
    }
}
