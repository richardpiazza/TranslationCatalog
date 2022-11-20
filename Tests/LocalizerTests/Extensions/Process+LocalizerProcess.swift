import XCTest
import class Foundation.Bundle

extension Process {
    class LocalizerProcess {
        
        var arguments: [String]? {
            get { process.arguments }
            set { process.arguments = newValue }
        }
        
        var output: String? {
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        }
        
        var error: String? {
            let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        }
        
        private let outputPipe: Pipe = Pipe()
        private let errorPipe: Pipe = Pipe()
        
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
        
        func run() throws {
            try process.run()
            process.waitUntilExit()
        }
    }
}
