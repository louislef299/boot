import Foundation
import XCTest
@testable import boot

// Mock FileManager for testing
class MockFileManager: FileManager {
    var fileExists = false
    var createDirectoryCalled = false
    var createDirectoryError: Error?
    var listContents: [String] = []
    var listContentsError: Error?
    var moveItemCalled = false
    var moveItemError: Error?
    private var _currentDirectoryPath: String = "/current/directory"
    
    override var currentDirectoryPath: String {
        return _currentDirectoryPath
    }
    
    override func fileExists(atPath path: String) -> Bool {
        return fileExists
    }
    
    override func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        createDirectoryCalled = true
        if let error = createDirectoryError {
            throw error
        }
    }
    
    override func contentsOfDirectory(atPath path: String) throws -> [String] {
        if let error = listContentsError {
            throw error
        }
        return listContents
    }
    
    override func moveItem(at srcURL: URL, to dstURL: URL) throws {
        moveItemCalled = true
        if let error = moveItemError {
            throw error
        }
    }
}

// Note: In a real-world implementation, we would implement proper dependency injection
// to allow for easier testing of command functionality with mocked FileManager

// For simplicity in tests, create a simplified alternative to XCTAssertFatalError
// Since testing fatal errors is complex and not the main focus here
func checkFatalErrorCondition(in function: String, condition: () -> Bool) {
    XCTAssertTrue(condition(), "Fatal error condition in \(function) should be detected")
}