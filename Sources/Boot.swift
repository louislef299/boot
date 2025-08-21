struct Boot {
    enum BootError: Error {
        case fileNotFound
    }

    var bootDir: String

    func boot(_ file: String) throws {
        throw BootError.fileNotFound
    }
}