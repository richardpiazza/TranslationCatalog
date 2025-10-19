import Foundation

extension JSONEncoder {
    static let filesystem: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        return encoder
    }()
}
