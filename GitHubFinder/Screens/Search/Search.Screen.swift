//
//  Search.Screen.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import SwiftUI

extension Search {
    struct Screen: View {
        @State private var model: ViewModel

        init(model: ViewModel) {
            self._model = .init(initialValue: model)
        }

        var body: some View {
            NavigationStack {
                content
                    .navigationTitle("search_screen_navigation_title")
                    .searchable(text: $model.query, prompt: "search_screen_search_prompt")
                    .onSubmit(of: .search) { model.search() }
                    .onChange(of: model.query) { model.debouncedSearch() }
                    .navigationDestination(for: GitHubUser.self) { user in
                        Profile.view(login: user.login, onUnauthorized: { model.signOut() })
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("search_screen_sign_out_button", systemImage: "rectangle.portrait.and.arrow.right") {
                                model.signOut()
                            }
                        }
                    }
            }
        }
    }
}

private extension Search.Screen {
    @ViewBuilder
    var content: some View {
        switch model.state {
        case .idle:
            ContentUnavailableView(
                "search_screen_empty_view_title",
                systemImage: "magnifyingglass",
                description: Text("search_screen_empty_view_description")
            )
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            list
        case .empty:
            ContentUnavailableView.search
        case .failed(let message):
            errorView(message)
        }
    }

    var list: some View {
        List {
            ForEach(model.users) { user in
                NavigationLink(value: user) {
                    Search.UserRow(user: user)
                }
                .onAppear { model.loadMoreIfNeeded(currentItem: user) }
            }

            if model.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }

    func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("search_screen_error_view_title", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("search_screen_retry_button") { model.search() }
        }
    }
}

#Preview {
    Search.view(onSignOut: {})
}
