//
//  ContentView.swift
//  Boot
//
//  Created by Louis LeFebvre on 10/9/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var fileManager = FileManagerService()

    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                if fileManager.currentDirectory.path != "/" {
                    Button(action: {
                        fileManager.navigateUp()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }

                Text("🥾Boot")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()
            }
            .padding()

            // Current path
            Text(fileManager.currentDirectory.path)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 8)

            Divider()

            // File grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(fileManager.files) { file in
                        FileItemView(file: file)
                            .onTapGesture {
                                if file.isDirectory {
                                    fileManager.navigateTo(url: file.url)
                                }
                            }
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.accent)
    }
}

struct FileItemView: View {
    let file: FileItem

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: file.icon)
                .font(.system(size: 40))
                .foregroundColor(file.isDirectory ? .blue : .primary)

            Text(file.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 32)
        }
        .frame(width: 100)
        .padding(8)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
}
