import Foundation

extension String {
    private static let darwinStringReplacement = "%@"
    private static let posixStringReplacement = "%s"

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

    var hasMultipleReplacements: Bool {
        (numberOfInstances("%@") > 1) || (numberOfInstances("%s") > 1)
    }

    func numberOfInstances(_ substring: String) -> Int {
        guard !isEmpty else {
            return 0
        }

        var count = 0

        var range: Range<String.Index>?
        while let match = self.range(of: substring, options: [], range: range) {
            count += 1
            range = Range(uncheckedBounds: (lower: match.upperBound, upper: endIndex))
        }

        return count
    }

    func decodingDarwinStrings() throws -> String {
        try replaceIn(self, pattern: Self.darwinStringReplacement, with: Self.posixStringReplacement)
    }

    func encodingDarwinStrings() throws -> String {
        try replaceIn(self, pattern: Self.posixStringReplacement, with: Self.darwinStringReplacement)
    }

    private func replaceIn(_ value: String, pattern: String, with: String) throws -> String {
        let regex = try Regex(pattern)
        var output = value
        let ranges = value.ranges(of: regex).reversed()
        for range in ranges {
            output.replaceSubrange(range, with: with)
        }
        return output
    }
}
