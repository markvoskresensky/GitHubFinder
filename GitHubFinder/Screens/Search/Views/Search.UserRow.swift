//
//  Search.UserRow.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import SwiftUI

extension Search {
    struct UserRow: View {
        let user: GitHubUser

        var body: some View {
            HStack(spacing: 12) {
                AvatarView(url: user.avatarURL, size: 44)
                Text(user.login)
                    .font(.body.weight(.medium))
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}
