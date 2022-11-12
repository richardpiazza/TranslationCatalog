import Foundation

protocol Document: Identifiable, Equatable, Codable {
    var id: UUID { get }
}

extension Document {
    var filename: String { id.uuidString + ".json" }
    
    func write(to directory: URL, using encoder: JSONEncoder) throws {
        let data = try encoder.encode(self)
        let url = URL(fileURLWithPath: directory.appendingPathComponent(filename).path)
        try data.write(to: url)
    }
    
    func remove(from directory: URL) throws {
        let url = URL(fileURLWithPath: directory.appendingPathComponent(filename).path)
        try FileManager.default.removeItem(at: url)
    }
}
