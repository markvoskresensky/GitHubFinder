//
//  Profile.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import SwiftUI

enum Profile {}

extension Profile {
    static func view(login: String) -> some View {
        let model = ViewModel(login: login, service: GitHubService())
        return Profile.Screen(model: model)
    }
}
