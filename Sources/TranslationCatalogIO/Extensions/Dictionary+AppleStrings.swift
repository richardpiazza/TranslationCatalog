import Foundation
import TranslationCatalog

extension [String: String] {
    init(data: Data) throws {
        self.init()

        let raw = String(data: data, encoding: .utf8) ?? ""
        let expression = try NSRegularExpression(pattern: "\"(.*)\"[ ]*=[ ]*\"(.*)\";")

        for line in raw.components(separatedBy: "\n") {
            let range = NSRange(location: 0, length: line.count)
            var components: [String] = []
            if let result = expression.firstMatch(in: line, options: .init(), range: range) {
                components = (1 ..< result.numberOfRanges).map {
                    let _range = result.range(at: $0)
                    let start = line.index(line.startIndex, offsetBy: _range.location)
                    let end = line.index(start, offsetBy: _range.length)
                    return String(line[start ..< end])
                }
            }

            if components.count > 1 {
                self[components[0]] = components[1]
            }
        }
    }

    /// Reimplementation of the `NSDictionary(contentsOf:)`
    init(contentsOf url: URL) throws {
        self.init()

        let raw = try String(contentsOf: url, encoding: .utf8)
        let expression = try NSRegularExpression(pattern: "\"(.*)\"[ ]*=[ ]*\"(.*)\";")

        for line in raw.components(separatedBy: "\n") {
            let range = NSRange(location: 0, length: line.count)
            var components: [String] = []
            if let result = expression.firstMatch(in: line, options: .init(), range: range) {
                components = (1 ..< result.numberOfRanges).map {
                    let _range = result.range(at: $0)
                    let start = line.index(line.startIndex, offsetBy: _range.location)
                    let end = line.index(start, offsetBy: _range.length)
                    return String(line[start ..< end])
                }
            }

            if components.count > 1 {
                self[components[0]] = components[1]
            }
        }
    }

    func expressions(
        defaultLanguage: Locale.LanguageCode = .default,
        comment: String? = nil,
        feature: String? = nil,
        language: Locale.LanguageCode,
        script: Locale.Script? = nil,
        region: Locale.Region? = nil
    ) -> [TranslationCatalog.Expression] {
        map { key, value -> TranslationCatalog.Expression in
            if defaultLanguage == language, script == nil, region == nil {
                return TranslationCatalog.Expression(
                    id: .zero,
                    key: key,
                    value: value,
                    languageCode: defaultLanguage,
                    context: comment,
                    feature: feature
                )
            } else {
                return TranslationCatalog.Expression(
                    id: .zero,
                    key: key,
                    value: "",
                    languageCode: defaultLanguage,
                    name: key,
                    context: comment,
                    feature: feature,
                    translations: [
                        Translation(
                            id: .zero,
                            expressionId: .zero,
                            language: language,
                            script: script,
                            region: region,
                            value: value
                        ),
                    ]
                )
            }
        }
    }
}
