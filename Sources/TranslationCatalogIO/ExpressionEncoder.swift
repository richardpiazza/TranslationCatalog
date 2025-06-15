import Foundation
import LocaleSupport
import Plot
import TranslationCatalog

/// Utility for encoding catalog `Translation`s for export/transfer.
public struct ExpressionEncoder {

    private init() {}

    /// Encode the first/primary `Translation` of each `Expression` in the collection.
    ///
    /// - throws: `Error`
    /// - parameters:
    ///   - expressions: The `Expression`s with `Translation`(s) to be encoded.
    ///   - fileFormat: Format in which the `data` should be interpreted.
    /// - returns: The encoded translations in the request format.
    @available(*, deprecated, renamed: "encodeTranslations(for:fileFormat:localeIdentifier:defaultOrFirst:)")
    public static func encodeTranslations(
        for expressions: [TranslationCatalog.Expression],
        fileFormat: FileFormat
    ) throws -> Data {
        try encodeTranslations(for: expressions, fileFormat: fileFormat, localeIdentifier: nil, defaultOrFirst: false)
    }

    /// Encode the a `Translation` of each `Expression` in the collection.
    ///
    /// - throws: `Error`
    /// - parameters:
    ///   - expressions: The `Expression`s with `Translation`(s) to be encoded.
    ///   - fileFormat: Format in which the `data` should be interpreted.
    ///   - localeIdentifier: The `Locale.Identifier` used to map a specific `Translation`.
    ///   - defaultOrFirst: Indicates a _default_ or _first_ translation is used when a locale-specific one is not found.
    /// - returns: The encoded translations in the request format.
    public static func encodeTranslations(
        for expressions: [TranslationCatalog.Expression],
        fileFormat: FileFormat,
        localeIdentifier: Locale.Identifier?,
        defaultOrFirst: Bool
    ) throws -> Data {
        switch fileFormat {
        case .androidXML:
            exportAndroid(expressions, localeIdentifier: localeIdentifier, defaultOrFirst: defaultOrFirst)
        case .appleStrings:
            exportApple(expressions, localeIdentifier: localeIdentifier, defaultOrFirst: defaultOrFirst)
        case .json:
            try exportJson(expressions, localeIdentifier: localeIdentifier, defaultOrFirst: defaultOrFirst)
        }
    }

    private static func exportAndroid(_ expressions: [TranslationCatalog.Expression], localeIdentifier: Locale.Identifier?, defaultOrFirst: Bool) -> Data {
        let sorted = expressions.sorted(by: { $0.key < $1.key })
        let xml = XML.make(with: sorted, localeIdentifier: localeIdentifier, defaultOrFirst: defaultOrFirst)
        let raw = xml.render(indentedBy: .spaces(2))
        return raw.data(using: .utf8) ?? Data()
    }

    private static func exportApple(_ expressions: [TranslationCatalog.Expression], localeIdentifier: Locale.Identifier?, defaultOrFirst: Bool) -> Data {
        let sorted = expressions.sorted(by: { $0.key < $1.key })
        var output: [String] = []

        for expression in sorted {
            let translation = defaultOrFirst ? expression.translationOrDefaultOrFirst(with: localeIdentifier) : expression.translation(with: localeIdentifier)
            guard let translation else {
                continue
            }

            output.append("\"\(expression.key)\" = \"\(translation.value.simpleAppleDictionaryEscaped())\";")
        }

        return output
            .joined(separator: "\n")
            .data(using: .utf8) ?? Data()
    }

    private static func exportJson(_ expressions: [TranslationCatalog.Expression], localeIdentifier: Locale.Identifier?, defaultOrFirst: Bool) throws -> Data {
        let filtered = expressions.compactMap(localeIdentifier: localeIdentifier, defaultOrFirst: defaultOrFirst)
        let sequence = filtered.map { [$0.key: $0.translations.first?.value ?? ""] }
        let dictionary = sequence.reduce(into: [String: String]()) { partialResult, pair in
            partialResult[pair.keys.first!] = pair.values.first!
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

        return try encoder.encode(dictionary)
    }
}
