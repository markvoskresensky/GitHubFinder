//
//  Profile.Screen.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import SwiftUI

extension Profile {
    struct Screen: View {
        @State private var model: ViewModel

        init(model: ViewModel) {
            _model = State(initialValue: model)
        }

        var body: some View {
            content
                .navigationTitle(model.user?.login ?? model.login)
                .navigationBarTitleDisplayMode(.inline)
                .task { await model.load() }
        }
    }
}

private extension Profile.Screen {
    @ViewBuilder
    var content: some View {
        switch model.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            errorView(message)
        case .loaded:
            loaded
        }
    }

    @ViewBuilder
    var loaded: some View {
        List {
            if let user = model.user {
                Section {
                    Profile.Header(user: user)
                        .listRowSeparator(.hidden)
                }
            }

            if model.repositories.isEmpty {
                Section("profile_screen_repositories_section_title") {
                    Text("profile_screen_no_repositories_text")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section(String(localized: "profile_screen_repositories_count_section_title",
                               defaultValue: "Repositories (\(model.repositories.count))")) {
                    ForEach(model.repositories) { repository in
                        repositoryLink(repository)
                            .onAppear { model.loadMoreIfNeeded(currentItem: repository) }
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
            }
        }
    }

    @ViewBuilder
    func repositoryLink(_ repository: Repository) -> some View {
        if let url = repository.htmlURL {
            Link(destination: url) {
                Profile.RepositoryRow(repository: repository)
            }
            .buttonStyle(.plain)
        } else {
            Profile.RepositoryRow(repository: repository)
        }
    }

    func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("profile_screen_error_view_text", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("profile_screen_retry_button") {
                Task { await model.load() }
            }
        }
    }
}

#Preview {
    Profile.view(login: "Test", onUnauthorized: {})
}
