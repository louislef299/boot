import ArgumentParser
import Foundation

@main
struct Boot: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Boot your files!")

  @Argument(
    help: "File to be parsed.",
    transform: URL.init(fileURLWithPath:)
  )
  var file: URL

  mutating func run() throws {
    print("\nReceived file \(file)\n")
    let destinationDirectory = URL(fileURLWithPath: "./.vscode")
    let fileManager = FileManager.default

    // Create destination directory if it doesn't exist
    if !fileManager.fileExists(atPath: destinationDirectory.path) {
        try? fileManager.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
    }

    // Set up destination file path
    let destinationFilePath = destinationDirectory.appendingPathComponent(file.lastPathComponent)

    // Move the file
    do {
        try fileManager.moveItem(at: file, to: destinationFilePath)
        print("Successfully moved file to \(destinationFilePath.path)")
    } catch {
        print("Error moving file: \(error)")
    }
  }
}
