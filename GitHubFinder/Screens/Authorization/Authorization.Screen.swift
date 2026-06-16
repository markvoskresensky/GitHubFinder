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
            Text("Sign in with your GitHub account to raise the rate limit and access more data.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Sign in with GitHub") { model.signIn() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func waiting(userCode: String, url: URL) -> some View {
        VStack(spacing: 16) {
            Text("Enter this code on GitHub:")
                .foregroundStyle(.secondary)
            Text(userCode)
                .font(.system(.largeTitle, design: .monospaced).weight(.bold))
                .textSelection(.enabled)
            Link("Open github.com/login/device", destination: url)
                .buttonStyle(.borderedProminent)
            ProgressView()
            Button("Cancel", role: .cancel) { model.cancel() }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var authorized: some View {
        ContentUnavailableView {
            Label("Signed in", systemImage: "checkmark.seal")
        } description: {
            Text("You're authorized with GitHub.")
        }
    }

    func failed(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Sign-in failed", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try again") { model.signIn() }
        }
    }
}
