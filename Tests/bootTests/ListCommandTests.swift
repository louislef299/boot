import XCTest
@testable import boot

final class ListCommandTests: XCTestCase {
    
    var mockFileManager: MockFileManager!
    var listCommand: Boot.List!
    
    override func setUp() {
        super.setUp()
        mockFileManager = MockFileManager()
        listCommand = Boot.List()
    }
    
    override func tearDown() {
        mockFileManager = nil
        listCommand = nil
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
        XCTAssertTrue(mockFileManager.createDirectoryCalled, "Directory should be validated before listing files")
    }
    
    func testRun_WithFiles_PrintsFiles() throws {
        // Setup
        mockFileManager.fileExists = true
        mockFileManager.listContents = ["file1.txt", "file2.txt"]
        
        // Execute - test getting boot files directly
        let files = try Boot.getBootFiles(Boot.bootDir, fileManager: mockFileManager)
        
        // Assert
        XCTAssertEqual(files, ["file1.txt", "file2.txt"])
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
        mockFileManager.listContentsError = NSError(domain: "test", code: 4, userInfo: nil)
        
        // Execute and Assert - unknown errors should propagate
        XCTAssertThrowsError(try Boot.getBootFiles(Boot.bootDir, fileManager: mockFileManager)) { error in
            XCTAssertEqual((error as NSError).domain, "test")
            XCTAssertEqual((error as NSError).code, 4)
        }
    }
    
    // Use shared MockFileManager from TestHelpers.swift
}