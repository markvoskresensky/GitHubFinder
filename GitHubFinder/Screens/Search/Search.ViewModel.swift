//
//  Search.ViewModel.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import Foundation

extension Search {
    @MainActor
    @Observable
    final class ViewModel {
        enum State {
            case idle
            case loading
            case loaded
            case empty
            case failed(String)
        }

        var query: String = ""
        private(set) var state: State = .idle
        private(set) var users: [GitHubUser] = []
        private(set) var isLoadingMore = false

        private let service: GitHubServicing
        private let onSignOut: () -> Void
        private var searchTask: Task<Void, Never>?
        private var loadedQuery = ""
        private var page = 1
        private var hasMore = false

        init(service: GitHubServicing, onSignOut: @escaping () -> Void) {
            self.service = service
            self.onSignOut = onSignOut
        }

        func search() {
            schedule(debounced: false)
        }

        func debouncedSearch() {
            schedule(debounced: true)
        }

        func loadMoreIfNeeded(currentItem: GitHubUser) {
            guard case .loaded = state, hasMore, !isLoadingMore else { return }
            guard currentItem.id == users.last?.id else { return }
            Task { [weak self] in await self?.loadNextPage() }
        }

        func signOut() {
            onSignOut()
        }
    }
}

private extension Search.ViewModel {
    func schedule(debounced: Bool) {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            state = .idle
            users = []
            return
        }

        searchTask = Task { [weak self] in
            if debounced {
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }
            }
            await self?.performSearch(trimmed)
        }
    }

    func performSearch(_ query: String) async {
        state = .loading
        do {
            let result = try await service.searchUsers(query: query, page: 1)
            guard !Task.isCancelled else { return }
            users = result.users
            hasMore = result.hasMore
            page = 1
            loadedQuery = query
            state = result.users.isEmpty ? .empty : .loaded
        } catch is CancellationError {
        } catch {
            guard !Task.isCancelled else { return }
            users = []
            state = .failed(error.localizedDescription)
        }
    }

    func loadNextPage() async {
        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = page + 1
        do {
            let result = try await service.searchUsers(query: loadedQuery, page: nextPage)
            users.append(contentsOf: result.users)
            page = nextPage
            hasMore = result.hasMore
        } catch {
            hasMore = false
        }
    }
}
