//
//  Authorization.ViewModel.swift
//  GitHubFinder
//
//  Created by Marko on 16.06.2026.
//

import Foundation

extension Authorization {
    @MainActor
    @Observable
    final class ViewModel {
        enum State {
            case idle
            case requestingCode
            case waitingForUser(userCode: String, verificationURL: URL)
            case authorized
            case failed(String)
        }

        private(set) var state: State = .idle

        private let service: GitHubAuthorizing
        private let tokenStore: TokenStoring
        private var flowTask: Task<Void, Never>?

        init(service: GitHubAuthorizing, tokenStore: TokenStoring) {
            self.service = service
            self.tokenStore = tokenStore
        }

        func signIn() {
            flowTask?.cancel()
            flowTask = Task { [weak self] in
                await self?.runFlow()
            }
        }

        func cancel() {
            flowTask?.cancel()
            state = .idle
        }
    }
}

private extension Authorization.ViewModel {
    func runFlow() async {
        state = .requestingCode
        do {
            let device = try await service.requestDeviceCode()
            state = .waitingForUser(userCode: device.userCode, verificationURL: device.verificationURI)

            let token = try await service.pollForAccessToken(
                deviceCode: device.deviceCode,
                interval: device.interval
            )
            tokenStore.save(token)
            state = .authorized
        } catch is CancellationError {
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
