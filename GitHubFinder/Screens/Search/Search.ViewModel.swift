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
            case loaded([GitHubUser])
            case empty
            case failed(String)
        }

        var query: String = ""
        private(set) var state: State = .idle

        private let service: GitHubServicing
        private let onSignOut: () -> Void
        private var searchTask: Task<Void, Never>?

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
            let users = try await service.searchUsers(query: query)
            guard !Task.isCancelled else { return }
            state = users.isEmpty ? .empty : .loaded(users)
        } catch is CancellationError {
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed(error.localizedDescription)
        }
    }
}
