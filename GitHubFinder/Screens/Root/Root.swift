//
//  Root.swift
//  GitHubFinder
//
//  Created by Marko on 16.06.2026.
//

import SwiftUI

enum Root {}

extension Root {
    static func view() -> some View {
        let model = ViewModel(tokenStore: TokenStore())
        return Root.Screen(model: model)
    }
}
