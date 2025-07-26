import Foundation
import XCTest

class LocalizerProcess {

    private static let fileManager = FileManager.default
    private static var directory: URL {
        URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
    }
    
    private let outputPipe: Pipe = Pipe()
    private let errorPipe: Pipe = Pipe()
    
    let executionIdentifier: UUID
    /// Path of the resource being interacted with.
    let url: URL
    /// Path where the execution can be run.
    let directory: URL
    
    private let cleanupDirectory: Bool
    
    var arguments: [String]? {
        get { process.arguments }
        set { process.arguments = newValue }
    }

    var output: String {
        String(
            decoding: outputPipe.fileHandleForReading.readDataToEndOfFile(),
            as: UTF8.self
        )
    }

    var error: String {
        String(
            decoding: errorPipe.fileHandleForReading.readDataToEndOfFile(),
            as: UTF8.self
        )
    }

    /// Returns path to the built products directory.
    private var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }

    private lazy var process: Process = {
        let process = Process()
        process.executableURL = productsDirectory.appendingPathComponent("localizer")
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        return process
    }()
    
    init() {
        executionIdentifier = UUID()
        let filename = [executionIdentifier.uuidString, "sqlite"].joined(separator: ".")
        url = Self.directory.appending(path: filename, directoryHint: .notDirectory)
        directory = Self.directory.appending(path: executionIdentifier.uuidString, directoryHint: .isDirectory)
        cleanupDirectory = false
    }
    
    init(copying resource: TestResource, cleanupDirectory: Bool = false, id: UUID = UUID()) throws {
        executionIdentifier = id
        directory = Self.directory.appending(path: executionIdentifier.uuidString, directoryHint: .isDirectory)
        self.cleanupDirectory = cleanupDirectory
        
        switch resource {
        case .directory(let url):
            guard let url else {
                throw URLError(.badURL)
            }
            
            self.url = directory
            try Self.fileManager.copyItem(at: url, to: directory)
        case .file(let url):
            guard let url else {
                throw URLError(.badURL)
            }
            
            let fileName = [executionIdentifier.uuidString, url.pathExtension].joined(separator: ".")
            let workingURL = Self.directory.appending(path: fileName, directoryHint: .notDirectory)
            self.url = workingURL
            try Self.fileManager.copyItem(at: url, to: workingURL)
        }
    }

    /// Execute the process and return the termination status
    @discardableResult
    func run() throws -> Int32 {
        try process.run()
        process.waitUntilExit()
        return process.terminationStatus
    }
    
    func runReporting(with arguments: [String]? = nil) throws -> (terminationStatus: Int32, output: String, error: String) {
        if let arguments {
            self.arguments = arguments
        }
        let terminationStatus = try run()
        return (terminationStatus, output, error)
    }
    
    func runOutputting(with arguments: [String]? = nil) throws -> String {
        if let arguments {
            self.arguments = arguments
        }
        try run()
        return output
    }
    
    func recycle() throws {
        if Self.fileManager.fileExists(atPath: url.path()) {
            try Self.fileManager.removeItem(at: url)
        }
        
        guard cleanupDirectory else {
            return
        }
        
        if Self.fileManager.fileExists(atPath: directory.path()) {
            try Self.fileManager.removeItem(at: directory)
        }
    }
}
