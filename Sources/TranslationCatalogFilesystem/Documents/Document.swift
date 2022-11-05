import Foundation

protocol Document: Identifiable, Equatable, Codable {
    var id: UUID { get }
}

extension Document {
    var filename: String { id.uuidString + ".json" }
    
    func write(to directory: URL, using encoder: JSONEncoder) throws {
        let data = try encoder.encode(self)
        
        let url: URL
        
        #if swift(>=5.7.1)
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            url = directory.appending(path: filename, directoryHint: .notDirectory)
        } else {
            url = directory.appendingPathComponent(filename)
        }
        #else
        url = directory.appendingPathComponent(filename)
        #endif
        
        try data.write(to: url)
    }
    
    func remove(from directory: URL) throws {
        let url: URL
        
        #if swift(>=5.7.1)
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            url = directory.appending(path: filename, directoryHint: .notDirectory)
        } else {
            url = directory.appendingPathComponent(filename)
        }
        #else
        url = directory.appendingPathComponent(filename)
        #endif
        
        try FileManager.default.removeItem(at: url)
    }
}
