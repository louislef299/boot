//
//  FileItem.swift
//  Boot
//
//  Created by Louis LeFebvre on 10/15/25.
//

import Foundation

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: URL
    let isDirectory: Bool

    var icon: String {
        if isDirectory {
            return "folder.fill"
        }

        let ext = url.pathExtension.lowercased()
        switch ext {
        case "txt", "md":
            return "doc.text.fill"
        case "pdf":
            return "doc.fill"
        case "jpg", "jpeg", "png", "gif", "heic":
            return "photo.fill"
        case "mp4", "mov", "avi":
            return "video.fill"
        case "mp3", "wav", "m4a":
            return "music.note"
        case "zip", "tar", "gz":
            return "doc.zipper"
        case "swift", "py", "js", "java", "cpp", "c", "h":
            return "chevron.left.forwardslash.chevron.right"
        default:
            return "doc.fill"
        }
    }
}
