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

    @Test("Есть токен при старте → authorized")
    func authorizedWhenTokenExists() {
        let store = MockTokenStore()
        store.save("gho_existing")
        let model = Root.ViewModel(tokenStore: store)

        #expect(model.isAuthorized)
    }

    @Test("Нет токена при старте → не authorized")
    func notAuthorizedWithoutToken() {
        let model = Root.ViewModel(tokenStore: MockTokenStore())

        #expect(!model.isAuthorized)
    }

    @Test("didAuthorize переключает в authorized")
    func didAuthorizeFlips() {
        let model = Root.ViewModel(tokenStore: MockTokenStore())

        model.didAuthorize()

        #expect(model.isAuthorized)
    }

    @Test("signOut сбрасывает флаг и удаляет токен")
    func signOutClearsToken() {
        let store = MockTokenStore()
        store.save("gho_existing")
        let model = Root.ViewModel(tokenStore: store)

        model.signOut()

        #expect(!model.isAuthorized)
        #expect(store.read() == nil)
    }
}
