//
//  Authorization.swift
//  GitHubFinder
//
//  Created by Marko on 16.06.2026.
//

import SwiftUI

enum Authorization {}

extension Authorization {
    static func view() -> some View {
        let model = ViewModel()
        return Authorization.Screen(model: model)
    }
}
