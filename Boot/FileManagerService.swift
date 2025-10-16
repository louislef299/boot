//
//  FileManagerService.swift
//  Boot
//
//  Created by Louis LeFebvre on 10/15/25.
//

import Foundation

class FileManagerService: ObservableObject {
    @Published var files: [FileItem] = []
    @Published var currentDirectory: URL

    init() {
        // Start with the user's home directory
        self.currentDirectory = FileManager.default.homeDirectoryForCurrentUser
        loadFiles()
    }

    func loadFiles() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: currentDirectory,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )

            files = fileURLs.map { url in
                let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
                return FileItem(
                    name: url.lastPathComponent,
                    url: url,
                    isDirectory: isDirectory
                )
            }.sorted { item1, item2 in
                // Directories first, then alphabetically
                if item1.isDirectory != item2.isDirectory {
                    return item1.isDirectory
                }
                return item1.name.localizedCaseInsensitiveCompare(item2.name) == .orderedAscending
            }
        } catch {
            print("Error loading files: \(error)")
            files = []
        }
    }

    func navigateTo(url: URL) {
        currentDirectory = url
        loadFiles()
    }

    func navigateUp() {
        let parentURL = currentDirectory.deletingLastPathComponent()
        if parentURL != currentDirectory {
            navigateTo(url: parentURL)
        }
    }
}
