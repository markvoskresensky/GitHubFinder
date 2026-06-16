//
//  AuthorizationViewModelTests.swift
//  GitHubFinderTests
//
//  Created by Marko on 16.06.2026.
//

import Testing
import Foundation
@testable import GitHubFinder

@MainActor
@Suite("Authorization.ViewModel")
struct AuthorizationViewModelTests {

    @Test("Начальное состояние — idle")
    func initialStateIsIdle() {
        let model = Authorization.ViewModel(service: MockGitHubAuthService(), tokenStore: MockTokenStore())
        #expect(model.state.isIdle)
    }

    @Test("Успешный вход → authorized и токен сохранён")
    func successfulSignInSavesToken() async throws {
        let service = MockGitHubAuthService()
        service.tokenResult = .success("gho_abc123")
        let store = MockTokenStore()
        let model = Authorization.ViewModel(service: service, tokenStore: store)

        model.signIn()
        try await waitUntil { model.state.isAuthorized }

        #expect(store.savedToken == "gho_abc123")
    }

    @Test("Во время ожидания показывается код пользователя")
    func showsUserCodeWhileWaiting() async throws {
        let service = MockGitHubAuthService()
        service.deviceCodeResult = .success(
            DeviceCodeResponse(
                deviceCode: "device-code",
                userCode: "ABCD-1234",
                verificationURI: URL(string: "https://github.com/login/device")!,
                expiresIn: 900,
                interval: 0
            )
        )
        service.hangOnPoll = true
        let model = Authorization.ViewModel(service: service, tokenStore: MockTokenStore())

        model.signIn()
        try await waitUntil { model.state.waitingUserCode != nil }

        #expect(model.state.waitingUserCode == "ABCD-1234")
    }

    @Test("Отмена возвращает в idle")
    func cancelReturnsToIdle() async throws {
        let service = MockGitHubAuthService()
        service.hangOnPoll = true
        let model = Authorization.ViewModel(service: service, tokenStore: MockTokenStore())

        model.signIn()
        try await waitUntil { model.state.waitingUserCode != nil }
        model.cancel()

        #expect(model.state.isIdle)
    }

    @Test("Ошибка запроса кода → failed, токен не сохранён")
    func deviceCodeFailureGivesFailed() async throws {
        let service = MockGitHubAuthService()
        service.deviceCodeResult = .failure(GitHubAuthError.deviceFlowDisabled)
        let store = MockTokenStore()
        let model = Authorization.ViewModel(service: service, tokenStore: store)

        model.signIn()
        try await waitUntil { model.state.failureMessage != nil }

        #expect(model.state.failureMessage == GitHubAuthError.deviceFlowDisabled.errorDescription)
        #expect(store.savedToken == nil)
    }

    @Test("Ошибка опроса токена → failed, токен не сохранён")
    func pollFailureGivesFailed() async throws {
        let service = MockGitHubAuthService()
        service.tokenResult = .failure(GitHubAuthError.accessDenied)
        let store = MockTokenStore()
        let model = Authorization.ViewModel(service: service, tokenStore: store)

        model.signIn()
        try await waitUntil { model.state.failureMessage != nil }

        #expect(store.savedToken == nil)
    }
}
