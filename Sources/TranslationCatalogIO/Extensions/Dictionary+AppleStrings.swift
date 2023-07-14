import Foundation
import LocaleSupport
import TranslationCatalog

extension Dictionary where Key == String, Value == String {
    init(data: Data) throws {
        self.init()
        
        let raw = String(data: data, encoding: .utf8) ?? ""
        let expression = try NSRegularExpression(pattern: "\"(.*)\"[ ]*=[ ]*\"(.*)\";")
        
        for line in raw.components(separatedBy: "\n") {
            let range = NSRange(location: 0, length: line.count)
            var components: [String] = []
            if let result = expression.firstMatch(in: line, options: .init(), range: range) {
                components = (1..<result.numberOfRanges).map {
                    let _range = result.range(at: $0)
                    let start = line.index(line.startIndex, offsetBy: _range.location)
                    let end = line.index(start, offsetBy: _range.length)
                    return String(line[start..<end])
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
                components = (1..<result.numberOfRanges).map {
                    let _range = result.range(at: $0)
                    let start = line.index(line.startIndex, offsetBy: _range.location)
                    let end = line.index(start, offsetBy: _range.length)
                    return String(line[start..<end])
                }
            }
            
            if components.count > 1 {
                self[components[0]] = components[1]
            }
        }
    }
    
    func expressions(
        defaultLanguage: LanguageCode = .default,
        comment: String? = nil,
        feature: String? = nil,
        language: LanguageCode,
        script: ScriptCode? = nil,
        region: RegionCode? = nil
    ) -> [Expression] {
        return self.map { (key, value) -> Expression in
            return Expression(
                uuid: .zero,
                key: key,
                name: key,
                defaultLanguage: defaultLanguage,
                context: comment,
                feature: feature,
                translations: [
                    Translation(uuid: .zero, expressionID: .zero, languageCode: language, scriptCode: script, regionCode: region, value: value)
                ]
            )
        }
    }
}
