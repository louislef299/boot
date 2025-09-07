import ArgumentParser
import Foundation

enum BootError: Error {
  case NoBootFiles(path: String)
}

@main
struct Boot: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Boot your files!",
    version: "v0.0.1",
    subcommands: [
      Move.self, 
      List.self, 
      Receive.self,
    ],
    defaultSubcommand: Move.self,
  )
  
  static let homeDirURL = FileManager.default.homeDirectoryForCurrentUser
  static let bootDir = URL(fileURLWithPath: "\(homeDirURL.path)/.boot")

  // Validate boot directory exists and create directory if it doesn't exist
  static func validateDir(_ dir: URL, fileManager: FileManager) {
    if !fileManager.fileExists(atPath: dir.path) {
        do {
          try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        } catch {
          fatalError("Failed to create directory \(dir.path): \(error)")
        }
    }
  }

  static func getBootFiles(_ dir: URL, fileManager: FileManager) throws -> [String] {
    let contents = try fileManager.contentsOfDirectory(atPath: Boot.bootDir.path)
    if contents.isEmpty {
      throw BootError.NoBootFiles(path: dir.path)
    }
    return contents
  }
}

extension Boot {
  struct Move: ParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "move",
      abstract: "Move a file to the boot directory",
      aliases: ["mv"]
    )
    
    @Argument(
      help: "File to boot.",
      transform: URL.init(fileURLWithPath:)
    )
    var files: [URL]
    
    mutating func run() throws {
      let fileManager = FileManager.default
      Boot.validateDir(Boot.bootDir, fileManager: fileManager)
      
      for file in files {
        let destinationFilePath = Boot.bootDir.appendingPathComponent(file.lastPathComponent)
        do {
            try fileManager.moveItem(at: file, to: destinationFilePath)
            print("booted \(file.relativeString)")
        } catch {
            print("Error moving file: \(error)")
        }
      }
    }
  }
  
  struct List: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "List files in the boot directory",
      aliases: ["ls"]
    )
    
    mutating func run() {
      let fileManager = FileManager.default
      Boot.validateDir(Boot.bootDir, fileManager: fileManager)

      do {
        let contents = try Boot.getBootFiles(Boot.bootDir, fileManager: fileManager)
        print("boot directory contents(\(Boot.bootDir.path)):")
        for f in contents {
          print("- \(f)")
        }
      } catch BootError.NoBootFiles(path: Boot.bootDir.path) {
        print("No files found in boot!")
      } catch {
        fatalError("Unknown error \(error)")
      }
    }
  }

  struct Receive: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Receive files from the boot directory",
      aliases: ["rec"]
    )

    @Argument(
      help: "File to be received."
    )
    var files: [String]

    mutating func run() {
      let fileManager = FileManager.default
      Boot.validateDir(Boot.bootDir, fileManager: fileManager)

      let all = files.contains("all")
      var moveCount = 0
      do {
        let contents = try Boot.getBootFiles(Boot.bootDir, fileManager: fileManager)
        for f in contents {
          if files.contains(f) || all {
            // found file in boot, bring it back
            do {
              try moveFileFromBoot(fileManager: fileManager, file: f)
              moveCount += 1
            } catch {
              print("Error moving file: \(error)")
            }
          }
        }
        if moveCount == 0 { print("no match(s) found for \(files)") }
      } catch BootError.NoBootFiles(path: Boot.bootDir.path) {
        print("No files found in boot!")
      } catch {
        fatalError("Unknown error \(error)")
      }
    }
  }
}

func moveFileFromBoot(fileManager: FileManager, file: String) throws {
  let destinationURL = URL(fileURLWithPath: fileManager.currentDirectoryPath).appendingPathComponent(file)
  if fileManager.fileExists(atPath: destinationURL.path) {
      fatalError("A file with the name \(file) already exists at destination")
  }

  try fileManager.moveItem(
    at: Boot.bootDir.appendingPathComponent(file), 
    to: destinationURL
  )
  print("recovered \(file)")
}
