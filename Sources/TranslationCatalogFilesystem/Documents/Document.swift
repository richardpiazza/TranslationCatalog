import Foundation

protocol Document: Equatable, Identifiable, Codable {
    var id: UUID { get }
}

extension Document {
    var filename: String { id.uuidString + ".json" }
}
