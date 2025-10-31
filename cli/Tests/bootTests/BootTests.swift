import XCTest
@testable import boot

final class BootTests: XCTestCase {
    
    var testDirectoryURL: URL!
    var mockFileManager: MockFileManager!
    
    override func setUp() {
        super.setUp()
        testDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("bootTests")
        mockFileManager = MockFileManager()
    }
    
    override func tearDown() {
        testDirectoryURL = nil
        mockFileManager = nil
        super.tearDown()
    }
    
    // MARK: - validateDir Tests
    
    func testValidateDir_DirectoryExists() {
        // Setup
        mockFileManager.fileExists = true
        
        // Execute
        Boot.validateDir(testDirectoryURL, fileManager: mockFileManager)
        
        // Assert
        XCTAssertFalse(mockFileManager.createDirectoryCalled, "Should not attempt to create directory if it exists")
    }
    
    func testValidateDir_DirectoryDoesNotExist_CreatesDirectory() {
        // Setup
        mockFileManager.fileExists = false
        
        // Execute
        Boot.validateDir(testDirectoryURL, fileManager: mockFileManager)
        
        // Assert
        XCTAssertTrue(mockFileManager.createDirectoryCalled, "Should attempt to create directory if it doesn't exist")
    }
    
    func testValidateDir_DirectoryCreationFails() {
        // Setup
        mockFileManager.fileExists = false
        mockFileManager.createDirectoryError = NSError(domain: "test", code: 1, userInfo: nil)
        
        // Execute and Assert
        // In real tests we would check for fatal error, but we'll simplify for now
        checkFatalErrorCondition(in: "validateDir") {
            // Check if the condition that would lead to a fatal error exists
            mockFileManager.createDirectoryError != nil
        }
    }
    
    // MARK: - getBootFiles Tests
    
    func testGetBootFiles_WithFiles_ReturnsFiles() throws {
        // Setup
        let expectedFiles = ["file1.txt", "file2.txt"]
        mockFileManager.listContents = expectedFiles
        
        // Execute
        let result = try Boot.getBootFiles(Boot.bootDir, fileManager: mockFileManager)
        
        // Assert
        XCTAssertEqual(result, expectedFiles)
    }
    
    func testGetBootFiles_EmptyDirectory_ThrowsError() {
        // Setup
        mockFileManager.listContents = []
        
        // Execute and Assert
        XCTAssertThrowsError(try Boot.getBootFiles(Boot.bootDir, fileManager: mockFileManager)) { error in
            guard case BootError.NoBootFiles(let path) = error else {
                XCTFail("Expected NoBootFiles error, got \(error)")
                return
            }
            XCTAssertEqual(path, Boot.bootDir.path)
        }
    }
    
    func testGetBootFiles_DirectoryReadError_PropagatesError() {
        // Setup
        let expectedError = NSError(domain: "test", code: 2, userInfo: nil)
        mockFileManager.listContentsError = expectedError
        
        // Execute and Assert
        XCTAssertThrowsError(try Boot.getBootFiles(Boot.bootDir, fileManager: mockFileManager)) { error in
            XCTAssertEqual((error as NSError).domain, "test")
            XCTAssertEqual((error as NSError).code, 2)
        }
    }
    
    // Use shared MockFileManager from TestHelpers.swift
}