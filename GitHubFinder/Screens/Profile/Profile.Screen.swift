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
                Section("Repositories") {
                    Text("This user has no public repositories.")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section("Repositories (\(model.repositories.count))") {
                    ForEach(model.repositories) { repository in
                        repositoryLink(repository)
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
            Label("Couldn't load profile", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry") {
                Task { await model.load() }
            }
        }
    }
}
