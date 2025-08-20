import ArgumentParser
import Foundation

struct BootOptions: ParsableCommand {
  @Flag(help: "Boot the object to the remote")
  var remote = false
}

let options = BootOptions.parseOrExit()

let fileManager = FileManager.default
let currentDirectoryPath = fileManager.currentDirectoryPath
print("Current directory: \(currentDirectoryPath)")

do {
    let contents = try fileManager.contentsOfDirectory(atPath: currentDirectoryPath)
    print("Contents of the current directory:")
    for item in contents {
        print("- \(item)")
    }
} catch {
    print("Error listing directory contents: \(error)")
}
