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
                .navigationTitle("authorization_screen_navigation_title")
        }
    }
}

private extension Authorization.Screen {
    @ViewBuilder
    var content: some View {
        switch model.state {
        case .idle:
            idle
        case .requestingCode:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .waitingForUser(let userCode, let url):
            waiting(userCode: userCode, url: url)
        case .authorized:
            authorized
        case .failed(let message):
            failed(message)
        }
    }

    var idle: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.badge.key")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("authorization_screen_intro_text")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("authorization_screen_sign_in_button") { model.signIn() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func waiting(userCode: String, url: URL) -> some View {
        VStack(spacing: 16) {
            Text("authorization_screen_enter_code_text")
                .foregroundStyle(.secondary)
            Text(verbatim: userCode)
                .font(.system(.largeTitle, design: .monospaced).weight(.bold))
                .textSelection(.enabled)
            Link("authorization_screen_open_device_link", destination: url)
                .buttonStyle(.borderedProminent)
            ProgressView()
            Button("authorization_screen_cancel_button", role: .cancel) { model.cancel() }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var authorized: some View {
        ContentUnavailableView {
            Label("authorization_screen_signed_in_title", systemImage: "checkmark.seal")
        } description: {
            Text("authorization_screen_signed_in_text")
        }
    }

    func failed(_ message: String) -> some View {
        ContentUnavailableView {
            Label("authorization_screen_error_view_title", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("authorization_screen_try_again_button") { model.signIn() }
        }
    }
}
