//
//  Profile.RepositoryRow.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import SwiftUI

extension Profile {
    struct RepositoryRow: View {
        let repository: Repository

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(repository.name)
                        .font(.body.weight(.semibold))
                    if repository.fork {
                        Image(systemName: "tuningfork")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 16) {
                    if let language = repository.language {
                        Label(language, systemImage: "circle.fill")
                    }
                    Label("\(repository.stargazersCount)", systemImage: "star")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}
