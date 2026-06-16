//
//  AvatarView.swift
//  GitHubFinder
//
//  Created by Marko on 15.06.2026.
//

import SwiftUI

struct AvatarView: View {
    let url: URL?
    var size: CGFloat = 44

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                placeholder
            case .empty:
                ProgressView()
            @unknown default:
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(.quaternary))
    }

    private var placeholder: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.quaternary)
    }
}
