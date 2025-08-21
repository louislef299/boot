import XCTest
import Foundation
@testable import boot

final class BootTests: XCTestCase {
    
    // Temporary directory for testing
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        
        // Create a temporary directory for testing
        tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("BootTests_\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        
        // Override the boot directory for testing
        Boot.bootDir = tempDirectory.appendingPathComponent("boot_dir")
    }
    
    override func tearDown() {
        // Clean up temporary directory after tests
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }
    
    // Test 1: Test that boot directory is created if it doesn't exist
    func testBootDirectoryCreation() throws {
        // This test will fail because Boot.bootDir is currently a let constant
        // and needs to be changed to a computed property or variable
        
        let moveCommand = Boot.Move()
        let testFile = tempDirectory.appendingPathComponent("test_file.txt")
        
        // Create a test file
        try "test content".write(to: testFile, atomically: true, encoding: .utf8)
        
        // Set the file property directly (not how it would work in real CLI)
        var command = moveCommand
        let mirror = Mirror(reflecting: command)
        for child in mirror.children {
            if child.label == "file" {
                // This is a hack to set the property - you'll need to refactor to make this testable
                // by creating a proper initializer or setter method
                (command as AnyObject).setValue(testFile, forKey: "file")
            }
        }
        
        // Run the command
        try command.run()
        
        // Verify boot directory was created
        var isDir: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: Boot.bootDir.path, isDirectory: &isDir))
        XCTAssertTrue(isDir.boolValue)
    }
    
    // Test 2: Test moving a file that doesn't exist
    func testMoveNonexistentFile() throws {
        // This will fail because your code doesn't properly handle files that don't exist
        
        let nonExistentFile = tempDirectory.appendingPathComponent("doesnt_exist.txt")
        
        // Create a new Move command
        var moveCommand = Boot.Move()
        moveCommand.file = nonExistentFile
        
        // This should throw an error, but currently it doesn't properly handle this case
        XCTAssertThrowsError(try moveCommand.run())
    }
    
    // Test 3: Test the List command with empty directory
    func testListEmptyDirectory() throws {
        // This will fail because your List command doesn't handle empty directories gracefully
        
        // Create boot directory but leave it empty
        try FileManager.default.createDirectory(at: Boot.bootDir, withIntermediateDirectories: true)
        
        // Capture output to verify the message
        let outputPipe = Pipe()
        let oldStdout = FileHandle.standardOutput
        FileHandle.standardOutput = outputPipe
        
        var listCommand = Boot.List()
        try listCommand.run()
        
        // Restore stdout
        FileHandle.standardOutput = oldStdout
        
        // Get captured output
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        // This will fail because your current implementation doesn't handle empty directories well
        XCTAssertTrue(output.contains("No files in boot directory"), 
                     "Output should indicate empty directory, but was: \(output)")
    }
    
    // Test 4: Test handling of directories instead of files
    func testMoveDirectory() throws {
        // This will fail because your current implementation doesn't check if the input is a directory
        
        // Create a directory to try to move
        let directoryToMove = tempDirectory.appendingPathComponent("directory_to_move")
        try FileManager.default.createDirectory(at: directoryToMove, withIntermediateDirectories: true)
        
        var moveCommand = Boot.Move()
        moveCommand.file = directoryToMove
        
        // This should throw an error, but your current implementation doesn't check file types
        XCTAssertThrowsError(try moveCommand.run())
    }
    
    // Test 5: Test handling file name conflicts
    func testFileNameConflict() throws {
        // This will fail because your code doesn't handle name conflicts
        
        // Create boot directory
        try FileManager.default.createDirectory(at: Boot.bootDir, withIntermediateDirectories: true)
        
        // Create a file in the boot directory
        let existingFile = Boot.bootDir.appendingPathComponent("conflict.txt")
        try "existing content".write(to: existingFile, atomically: true, encoding: .utf8)
        
        // Create a file with the same name to try to move
        let newFile = tempDirectory.appendingPathComponent("conflict.txt")
        try "new content".write(to: newFile, atomically: true, encoding: .utf8)
        
        var moveCommand = Boot.Move()
        moveCommand.file = newFile
        
        // Running this should throw an error or handle the conflict somehow
        XCTAssertThrowsError(try moveCommand.run())
    }
}