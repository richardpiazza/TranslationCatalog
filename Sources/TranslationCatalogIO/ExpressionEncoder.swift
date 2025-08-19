import Foundation
import Plot
import TranslationCatalog

/// Utility for encoding catalog `Translation`s for export/transfer.
public struct ExpressionEncoder {

    private init() {}

    /// Encode the translation value for the provided expressions.
    ///
    /// - parameters:
    ///   - expressions: the `Expression`s to be encoded.
    ///   - locale: The `Locale` for which values should be encoded.
    ///   - fallback: Indicates whether the `Expression.defaultValue` should be used
    ///              if no locale-specific `Translation` is found.
    ///   - format: Format in which the `data` should be encoded.
    public static func encodeValues(
        for expressions: [TranslationCatalog.Expression],
        locale: Locale,
        fallback: Bool,
        format: FileFormat
    ) throws -> Data {
        switch format {
        case .androidXML:
            let sorted = expressions.sorted(by: { $0.key < $1.key })
            let xml = XML.make(
                with: sorted,
                locale: locale,
                fallback: fallback
            )
            let raw = xml.render(indentedBy: .spaces(2))
            return raw.data(using: .utf8) ?? Data()
        case .appleStrings:
            let sorted = expressions.sorted(by: { $0.key < $1.key })
            var output: [String] = []

            for expression in sorted {
                let translation = fallback ? expression.valueOrDefault(for: locale) : expression.value(for: locale)
                guard let translation else {
                    continue
                }

                let value = try translation
                    .encodingDarwinStrings()
                    .simpleAppleDictionaryEscaped()

                output.append("\"\(expression.key)\" = \"\(value)\";")
            }

            return output
                .joined(separator: "\n")
                .data(using: .utf8) ?? Data()
        case .json:
            let filtered = expressions.compactMap(locale: locale, fallback: fallback)
            let sequence = filtered.map { [$0.key: $0.valueOrDefault(for: locale)] }
            let dictionary = sequence.reduce(into: [String: String]()) { partialResult, pair in
                partialResult[pair.keys.first!] = pair.values.first!
            }

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

            return try encoder.encode(dictionary)
        }
    }
}
