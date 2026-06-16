//
//  MockGitHubAuthService.swift
//  GitHubFinderTests
//
//  Created by Marko on 16.06.2026.
//

import Foundation
@testable import GitHubFinder

final class MockGitHubAuthService: GitHubAuthorizing, @unchecked Sendable {
    var deviceCodeResult: Result<DeviceCodeResponse, Error> = .success(
        DeviceCodeResponse(
            deviceCode: "device-code",
            userCode: "WDJB-MJHT",
            verificationURI: URL(string: "https://github.com/login/device")!,
            expiresIn: 900,
            interval: 0
        )
    )
    var tokenResult: Result<String, Error> = .success("gho_testtoken")
    var hangOnPoll = false

    private(set) var pollCallCount = 0

    func requestDeviceCode() async throws -> DeviceCodeResponse {
        try deviceCodeResult.get()
    }

    func pollForAccessToken(deviceCode: String, interval: Int) async throws -> String {
        pollCallCount += 1
        if hangOnPoll {
            try await Task.sleep(for: .seconds(60))
        }
        return try tokenResult.get()
    }
}
