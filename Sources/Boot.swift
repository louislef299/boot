import ArgumentParser
import Foundation

@main
struct Boot: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Boot your files!",
    subcommands: [Move.self, List.self],
    defaultSubcommand: Move.self
  )
  
  static let bootDir = URL(fileURLWithPath: "./.vscode")
}

extension Boot {
  struct Move: ParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "move",
      abstract: "Move a file to the boot directory",
      aliases: ["mv"]
    )
    
    @Argument(
      help: "File to be parsed.",
      transform: URL.init(fileURLWithPath:)
    )
    var file: URL
    
    mutating func run() throws {
      print("\nReceived file \(file)\n")
      let fileManager = FileManager.default
      
      // Create destination directory if it doesn't exist
      if !fileManager.fileExists(atPath: Boot.bootDir.path) {
          try? fileManager.createDirectory(at: Boot.bootDir, withIntermediateDirectories: true)
      }
      
      // Set up destination file path
      let destinationFilePath = Boot.bootDir.appendingPathComponent(file.lastPathComponent)
      
      // Move the file
      do {
          try fileManager.moveItem(at: file, to: destinationFilePath)
          print("Successfully moved file to \(destinationFilePath.path)")
      } catch {
          print("Error moving file: \(error)")
      }
    }
  }
  
  struct List: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "List files in the boot directory",
      aliases: ["ls"]
    )
    
    mutating func run() {
      print("Files found in boot directory \(Boot.bootDir.path)")
      let fileManager = FileManager.default
      do {
        let contents = try fileManager.contentsOfDirectory(atPath: Boot.bootDir.path)

        if contents.isEmpty {
            print("No files in boot directory")
            return
        }
        
        for file in contents {
          print("- \(file)")
        }
      } catch {
        print("Error listing directory: \(error)")
      }
    }
  }
}
