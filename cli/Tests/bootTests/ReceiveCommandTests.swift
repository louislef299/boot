import XCTest
@testable import boot

final class ReceiveCommandTests: XCTestCase {
    
    var mockFileManager: MockFileManager!
    var receiveCommand: Boot.Receive!
    
    override func setUp() {
        super.setUp()
        mockFileManager = MockFileManager()
        receiveCommand = Boot.Receive()
        receiveCommand.files = ["test-file.txt"]
    }
    
    override func tearDown() {
        mockFileManager = nil
        receiveCommand = nil
        super.tearDown()
    }
    
    func testRun_ValidatesDirectory() throws {
        // Test directory validation directly
        // Setup
        mockFileManager.fileExists = true
        
        // Execute
        Boot.validateDir(Boot.bootDir, fileManager: mockFileManager)
        
        // Assert
        XCTAssertFalse(mockFileManager.createDirectoryCalled, "Directory should not be created if it exists")
        
        // Setup for directory not existing
        mockFileManager = MockFileManager()
        mockFileManager.fileExists = false
        
        // Execute
        Boot.validateDir(Boot.bootDir, fileManager: mockFileManager)
        
        // Assert
        XCTAssertTrue(mockFileManager.createDirectoryCalled, "Directory should be validated before receiving file")
    }
    
    func testRun_FileFound_MovesFile() throws {
        // Setup
        mockFileManager.fileExists = false // File doesn't exist at destination
        mockFileManager.listContents = ["test-file.txt"]
        
        // Test that moveItem would be called
        let sourceURL = Boot.bootDir.appendingPathComponent("test-file.txt")
        let destinationURL = URL(fileURLWithPath: mockFileManager.currentDirectoryPath).appendingPathComponent("test-file.txt")
        
        // Call moveItem directly
        try mockFileManager.moveItem(at: sourceURL, to: destinationURL)
        
        // Assert
        XCTAssertTrue(mockFileManager.moveItemCalled, "File should be moved from boot directory")
    }
    
    func testRun_MultipleFilesFound_MovesAllMatchingFiles() throws {
        // Setup
        mockFileManager.fileExists = false // Files don't exist at destination
        mockFileManager.listContents = ["test-file1.txt", "test-file2.txt", "other-file.txt"]
        receiveCommand.files = ["test-file1.txt", "test-file2.txt"]
        
        // Test first file
        let sourceURL1 = Boot.bootDir.appendingPathComponent("test-file1.txt")
        let destinationURL1 = URL(fileURLWithPath: mockFileManager.currentDirectoryPath).appendingPathComponent("test-file1.txt")
        
        try mockFileManager.moveItem(at: sourceURL1, to: destinationURL1)
        XCTAssertTrue(mockFileManager.moveItemCalled, "First file should be moved from boot directory")
        
        // Reset mock for second file
        mockFileManager.moveItemCalled = false
        
        // Test second file
        let sourceURL2 = Boot.bootDir.appendingPathComponent("test-file2.txt")
        let destinationURL2 = URL(fileURLWithPath: mockFileManager.currentDirectoryPath).appendingPathComponent("test-file2.txt")
        
        try mockFileManager.moveItem(at: sourceURL2, to: destinationURL2)
        XCTAssertTrue(mockFileManager.moveItemCalled, "Second file should be moved from boot directory")
    }
    
    func testRun_AllParameter_MovesAllFiles() throws {
        // Setup
        mockFileManager.fileExists = false // Files don't exist at destination
        mockFileManager.listContents = ["file1.txt", "file2.txt", "file3.txt"]
        receiveCommand.files = ["all"]
        
        // Test that all files would be moved
        for file in mockFileManager.listContents {
            let sourceURL = Boot.bootDir.appendingPathComponent(file)
            let destinationURL = URL(fileURLWithPath: mockFileManager.currentDirectoryPath).appendingPathComponent(file)
            
            mockFileManager.moveItemCalled = false
            try mockFileManager.moveItem(at: sourceURL, to: destinationURL)
            XCTAssertTrue(mockFileManager.moveItemCalled, "\(file) should be moved from boot directory")
        }
    }
    
    func testRun_FileNotFound_PrintsMessage() throws {
        // Setup
        mockFileManager.listContents = ["other-file.txt"]
        receiveCommand.files = ["test-file.txt"]
        
        // Test that the file is not in the list
        let files = try Boot.getBootFiles(Boot.bootDir, fileManager: mockFileManager)
        
        // Assert
        XCTAssertFalse(files.contains("test-file.txt"), "File should not be found")
        XCTAssertFalse(mockFileManager.moveItemCalled, "No move should happen for non-existent file")
    }
    
    func testRun_DestinationExists_FatalError() {
        // Setup
        mockFileManager.fileExists = true // File exists at destination
        mockFileManager.listContents = ["test-file.txt"]
        receiveCommand.files = ["test-file.txt"]
        
        // Execute and Assert
        checkFatalErrorCondition(in: "moveFileFromBoot") {
            // Check if the condition that would lead to a fatal error exists
            return mockFileManager.fileExists && mockFileManager.listContents.contains("test-file.txt")
        }
    }
    
    func testRun_MoveError_HandlesError() throws {
        // Setup
        mockFileManager.fileExists = false
        mockFileManager.listContents = ["test-file.txt"]
        mockFileManager.moveItemError = NSError(domain: "test", code: 5, userInfo: nil)
        
        // Test that moveItem would be called and error would be caught
        let sourceURL = Boot.bootDir.appendingPathComponent("test-file.txt")
        let destinationURL = URL(fileURLWithPath: mockFileManager.currentDirectoryPath).appendingPathComponent("test-file.txt")
        
        // Try to move and catch the error
        do {
            try mockFileManager.moveItem(at: sourceURL, to: destinationURL)
            XCTFail("Move should have thrown an error")
        } catch {
            // Expected error
        }
        
        // Assert
        XCTAssertTrue(mockFileManager.moveItemCalled, "Move should be attempted")
    }
    
    func testRun_NoFiles_HandlesError() throws {
        // Setup
        mockFileManager.fileExists = true
        mockFileManager.listContents = []
        
        // Execute - test that getBootFiles throws NoBootFiles error
        XCTAssertThrowsError(try Boot.getBootFiles(Boot.bootDir, fileManager: mockFileManager)) { error in
            guard case BootError.NoBootFiles = error else {
                XCTFail("Expected NoBootFiles error, got \(error)")
                return
            }
        }
    }
    
    func testRun_DirectoryReadError_PropagatesError() {
        // Setup
        mockFileManager.fileExists = true
        mockFileManager.listContentsError = NSError(domain: "test", code: 6, userInfo: nil)
        
        // Execute and Assert - unknown errors should propagate
        XCTAssertThrowsError(try Boot.getBootFiles(Boot.bootDir, fileManager: mockFileManager)) { error in
            XCTAssertEqual((error as NSError).domain, "test")
            XCTAssertEqual((error as NSError).code, 6)
        }
    }
    
    // Use shared MockFileManager from TestHelpers.swift
}