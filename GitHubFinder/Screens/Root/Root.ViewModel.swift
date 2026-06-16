//
//  Root.ViewModel.swift
//  GitHubFinder
//
//  Created by Marko on 16.06.2026.
//

import Foundation

extension Root {
    @MainActor
    @Observable
    final class ViewModel {
        private(set) var isAuthorized: Bool

        private let tokenStore: TokenStoring

        init(tokenStore: TokenStoring) {
            self.tokenStore = tokenStore
            isAuthorized = tokenStore.read() != nil
        }

        func didAuthorize() {
            isAuthorized = true
        }

        func signOut() {
            tokenStore.delete()
            isAuthorized = false
        }
    }
}
