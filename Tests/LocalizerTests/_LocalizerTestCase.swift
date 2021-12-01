import XCTest
import class Foundation.Bundle

class _LocalizerTestCase: XCTestCase {
    
    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }
    
    let outputPipe: Pipe = Pipe()
    let errorPipe: Pipe = Pipe()
    
    lazy var process: Process = {
        let process = Process()
        process.executableURL = productsDirectory.appendingPathComponent("localizer")
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        return process
    }()
    
    var output: String? {
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
    
    var error: String? {
        let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
    
    let fileManager: FileManager = .default
    let executionId = UUID()
    var path: String { "\(executionId.uuidString).sqlite" }
    
    func caseUrl() throws -> URL {
        try fileManager.url(for: path)
    }
    
    func recycle() throws {
        let url = try caseUrl()
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }
        
        try fileManager.removeItem(at: url)
    }
    
    override func tearDownWithError() throws {
        try recycle()
        try super.tearDownWithError()
    }
}

extension FileManager {
    func url(for filename: String) throws -> URL {
        // Absolute Path?
        let absoluteURL = URL(fileURLWithPath: filename)
        if fileExists(atPath: absoluteURL.path) {
            return absoluteURL
        }
        
        // Relative Path?
        let directory = URL(fileURLWithPath: currentDirectoryPath, isDirectory: true)
        let relativeURL = directory.appendingPathComponent(filename)
        return relativeURL
    }
}
