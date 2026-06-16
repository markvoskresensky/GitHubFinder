//
//  Root.Screen.swift
//  GitHubFinder
//
//  Created by Marko on 16.06.2026.
//

import SwiftUI

extension Root {
    struct Screen: View {
        @State private var model: ViewModel

        init(model: ViewModel) {
            _model = State(initialValue: model)
        }

        var body: some View {
            if model.isAuthorized {
                Search.view(onSignOut: { model.signOut() })
            } else {
                Authorization.view(onAuthorized: { model.didAuthorize() })
            }
        }
    }
}
