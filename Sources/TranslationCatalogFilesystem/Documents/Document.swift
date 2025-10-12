import Foundation

protocol Document: Equatable, Identifiable, Codable {
    var id: UUID { get }
}

extension Document {
    var filename: String { id.uuidString + ".json" }
    
    func write(to directory: URL, using encoder: JSONEncoder) throws {
        let data = try encoder.encode(self)
        let url = URL(fileURLWithPath: directory.appendingPathComponent(filename).path)
        try data.write(to: url)
    }
    
    func write(to wrapper: FileWrapper, using encoder: JSONEncoder) throws {
        let data = try encoder.encode(self)
        try remove(from: wrapper)
        wrapper.addRegularFile(withContents: data, preferredFilename: filename)
    }

    func remove(from directory: URL) throws {
        let url = URL(fileURLWithPath: directory.appendingPathComponent(filename).path)
        try FileManager.default.removeItem(at: url)
    }
    
    func remove(from wrapper: FileWrapper) throws {
        guard let existing = wrapper.fileWrappers?[filename] else {
            return
        }
        
        wrapper.removeFileWrapper(existing)
    }
}
