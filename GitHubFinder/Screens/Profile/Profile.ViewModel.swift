//
//  Profile.ViewModel.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import Foundation

extension Profile {
    @MainActor
    @Observable
    final class ViewModel {
        enum State {
            case loading
            case loaded
            case failed(String)
        }

        let login: String
        private(set) var state: State = .loading
        private(set) var user: UserDetail?
        private(set) var repositories: [Repository] = []

        private let service: GitHubServicing

        init(login: String, service: GitHubServicing) {
            self.login = login
            self.service = service
        }

        func load() async {
            state = .loading
            do {
                async let userRequest = service.user(login: login)
                async let reposRequest = service.repositories(login: login)
                let (user, repositories) = try await (userRequest, reposRequest)

                self.user = user
                self.repositories = Self.sorted(repositories)
                state = .loaded
            } catch {
                state = .failed(error.localizedDescription)
            }
        }
    }
}

private extension Profile.ViewModel {
    static func sorted(_ repositories: [Repository]) -> [Repository] {
        repositories.sorted { lhs, rhs in
            if lhs.fork != rhs.fork { return !lhs.fork }
            return lhs.stargazersCount > rhs.stargazersCount
        }
    }
}
