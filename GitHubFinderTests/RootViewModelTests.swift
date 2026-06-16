//
//  RootViewModelTests.swift
//  GitHubFinderTests
//
//  Created by Marko on 16.06.2026.
//

import Testing
@testable import GitHubFinder

@MainActor
@Suite("Root.ViewModel")
struct RootViewModelTests {

    @Test("Token present at start → authorized")
    func authorizedWhenTokenExists() {
        let store = MockTokenStore()
        store.save("gho_existing")
        let model = Root.ViewModel(tokenStore: store)

        #expect(model.isAuthorized)
    }

    @Test("No token at start → not authorized")
    func notAuthorizedWithoutToken() {
        let model = Root.ViewModel(tokenStore: MockTokenStore())

        #expect(!model.isAuthorized)
    }

    @Test("didAuthorize switches to authorized")
    func didAuthorizeFlips() {
        let model = Root.ViewModel(tokenStore: MockTokenStore())

        model.didAuthorize()

        #expect(model.isAuthorized)
    }

    @Test("signOut clears the flag and deletes the token")
    func signOutClearsToken() {
        let store = MockTokenStore()
        store.save("gho_existing")
        let model = Root.ViewModel(tokenStore: store)

        model.signOut()

        #expect(!model.isAuthorized)
        #expect(store.read() == nil)
    }
}
