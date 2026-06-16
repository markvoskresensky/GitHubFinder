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
        private(set) var isLoadingMore = false

        private let service: GitHubServicing
        private var page = 1
        private var hasMore = false

        init(login: String, service: GitHubServicing) {
            self.login = login
            self.service = service
        }

        func load() async {
            state = .loading
            do {
                async let userRequest = service.user(login: login)
                async let reposRequest = service.repositories(login: login, page: 1)
                let (user, reposPage) = try await (userRequest, reposRequest)

                self.user = user
                repositories = reposPage.repos
                hasMore = reposPage.hasMore
                page = 1
                state = .loaded
            } catch {
                state = .failed(error.localizedDescription)
            }
        }

        func loadMoreIfNeeded(currentItem: Repository) {
            guard case .loaded = state, hasMore, !isLoadingMore else { return }
            guard currentItem.id == repositories.last?.id else { return }
            Task { [weak self] in await self?.loadNextPage() }
        }
    }
}

private extension Profile.ViewModel {
    func loadNextPage() async {
        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = page + 1
        do {
            let result = try await service.repositories(login: login, page: nextPage)
            repositories.append(contentsOf: result.repos)
            page = nextPage
            hasMore = result.hasMore
        } catch {
            hasMore = false
        }
    }
}
