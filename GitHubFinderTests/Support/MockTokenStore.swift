//
//  MockTokenStore.swift
//  GitHubFinderTests
//
//  Created by Marko on 16.06.2026.
//

import Foundation
@testable import GitHubFinder

final class MockTokenStore: TokenStoring, @unchecked Sendable {
    private(set) var savedToken: String?

    func save(_ token: String) {
        savedToken = token
    }

    func read() -> String? {
        savedToken
    }

    func delete() {
        savedToken = nil
    }
}
