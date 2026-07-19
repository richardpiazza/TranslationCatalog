import Foundation

extension FileManager {
    func directory(forPath path: String, of url: URL) throws -> URL {
        let url = url.appending(path: path, directoryHint: .isDirectory)
        if !fileExists(atPath: url.path()) {
            try createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }
}
