import Foundation

extension String {
    /// Regex pattern for inline substitutions.
    ///
    /// Matches:
    /// * **token**: Starts with `%`
    /// * **position** Optional positional indication `1$`
    /// * **type** Ends with one of `s` (string), `ld` (int), `llu` (unsigned int), `lf` (float), `@` (Darwin object)
    private static let substitutionPattern = #"(?<token>%)(?<position>\d+\$)?(?<type>s|ld|llu|lf|@)"#
    private static let darwinStringToken = "@"
    private static let posixStringToken = "s"

    func simpleAppleDictionaryEscaped() -> String {
        let replacements: [(Character, String)] = [
            (#"""#, #"\""#),
            ("\u{00a0}", "\\U00A0"), // Non-Breaking Space
        ]

        var updated = self

        for (character, replacement) in replacements {
            updated = updated.replacingOccurrences(of: String(describing: character), with: replacement, range: nil)
        }

        return updated
    }

    func simpleAndroidXMLEscaped() -> String {
        let replacements: [(Character, String)] = [
            ("&", "&amp;"),
            (#"""#, #"\""#),
            ("'", "\\'"),
            ("<", "&lt;"),
            (">", "&gt;"),
            (" ", "&#160;"), // Non-Breaking Space
        ]

        var updated = self

        for (character, replacement) in replacements {
            updated = updated.replacingOccurrences(of: String(describing: character), with: replacement, range: nil)
        }

        return updated
    }

    var substitutionRanges: [Range<Self.Index>] {
        get throws {
            let regex = try Regex(Self.substitutionPattern)
            return ranges(of: regex)
        }
    }

    var hasMultipleReplacements: Bool {
        do {
            return try substitutionRanges.count > 1
        } catch {
            return false
        }
    }

    func replaceToken(_ token: String, with replacement: String) throws -> String {
        let ranges = try substitutionRanges
        var modified = self

        for range in ranges.reversed() {
            let substring = modified[range]
            if substring.hasSuffix(token) {
                let lowerBound = modified.index(range.upperBound, offsetBy: -token.count)
                modified.replaceSubrange(lowerBound ..< range.upperBound, with: replacement)
            }
        }

        return modified
    }

    func decodingDarwinStrings() throws -> String {
        try replaceToken(Self.darwinStringToken, with: Self.posixStringToken)
    }

    func encodingDarwinStrings() throws -> String {
        try replaceToken(Self.posixStringToken, with: Self.darwinStringToken)
    }
}
