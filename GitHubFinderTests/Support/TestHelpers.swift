//
//  TestHelpers.swift
//  GitHubFinderTests
//
//  Created by Marko on 15.06.2026.
//

import Testing
@testable import GitHubFinder

@MainActor
func waitUntil(
    timeout: Duration = .seconds(2),
    _ condition: () -> Bool
) async throws {
    let deadline = ContinuousClock.now.advanced(by: timeout)
    while !condition() {
        if ContinuousClock.now >= deadline {
            Issue.record("Timed out waiting for condition")
            return
        }
        try await Task.sleep(for: .milliseconds(5))
    }
}

extension Search.ViewModel.State {
    var isIdle: Bool { if case .idle = self { true } else { false } }
    var isLoading: Bool { if case .loading = self { true } else { false } }
    var isLoaded: Bool { if case .loaded = self { true } else { false } }
    var isEmpty: Bool { if case .empty = self { true } else { false } }
    var failureMessage: String? { if case .failed(let message) = self { message } else { nil } }
}

extension Profile.ViewModel.State {
    var isLoading: Bool { if case .loading = self { true } else { false } }
    var isLoaded: Bool { if case .loaded = self { true } else { false } }
    var failureMessage: String? { if case .failed(let message) = self { message } else { nil } }
}

extension Authorization.ViewModel.State {
    var isIdle: Bool { if case .idle = self { true } else { false } }
    var isAuthorized: Bool { if case .authorized = self { true } else { false } }
    var waitingUserCode: String? { if case .waitingForUser(let code, _) = self { code } else { nil } }
    var failureMessage: String? { if case .failed(let message) = self { message } else { nil } }
}
