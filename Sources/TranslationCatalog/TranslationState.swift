public struct TranslationState: Hashable, Sendable {
    public let rawValue: StringLiteralType

    public static let needsReview: Self = "needs_review"
    public static let new: Self = "new"
    public static let translated: Self = "translated"
}

extension TranslationState: CaseIterable {
    public static let allCases: [TranslationState] = [
        .needsReview,
        .new,
        .translated,
    ]
}

extension TranslationState: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension TranslationState: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        rawValue = value
    }
}

extension TranslationState: Identifiable {
    public var id: String { rawValue }
}
