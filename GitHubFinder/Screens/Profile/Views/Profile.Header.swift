//
//  Profile.Header.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import SwiftUI

extension Profile {
    struct Header: View {
        let user: UserDetail

        var body: some View {
            VStack(spacing: 12) {
                AvatarView(url: user.avatarURL, size: 96)

                VStack(spacing: 4) {
                    if let name = user.name, !name.isEmpty {
                        Text(name)
                            .font(.title2.bold())
                    }
                    Text("@\(user.login)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let bio = user.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.body)
                        .multilineTextAlignment(.center)
                }

                metadata

                stats

                if let url = user.htmlURL {
                    Link(destination: url) {
                        Label("Open on GitHub", systemImage: "arrow.up.right.square")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

private extension Profile.Header {
    @ViewBuilder
    var metadata: some View {
        let items: [(String, String)] = [
            ("building.2", user.company),
            ("mappin.and.ellipse", user.location),
            ("link", user.blog?.isEmpty == false ? user.blog : nil)
        ].compactMap { symbol, value in
            value.map { (symbol, $0) }
        }

        if !items.isEmpty {
            VStack(spacing: 4) {
                ForEach(items, id: \.1) { symbol, value in
                    Label(value, systemImage: symbol)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    var stats: some View {
        HStack(spacing: 24) {
            stat(value: user.publicRepos, title: "Repositories")
            stat(value: user.followers, title: "Followers")
            stat(value: user.following, title: "Following")
        }
        .padding(.top, 4)
    }

    func stat(value: Int, title: LocalizedStringKey) -> some View {
        VStack(spacing: 2) {
            Text(value, format: .number)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
