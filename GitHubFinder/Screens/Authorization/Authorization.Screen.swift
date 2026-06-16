//
//  Authorization.Screen.swift
//  GitHubFinder
//
//  Created by Marko on 16.06.2026.
//

import SwiftUI

extension Authorization {
    struct Screen: View {
        @State private var model: ViewModel

        init(model: ViewModel) {
            _model = State(initialValue: model)
        }

        var body: some View {
            content
                .navigationTitle("Authorization")
        }
    }
}

private extension Authorization.Screen {
    @ViewBuilder
    var content: some View {
        Text("Authorization")
    }
}
