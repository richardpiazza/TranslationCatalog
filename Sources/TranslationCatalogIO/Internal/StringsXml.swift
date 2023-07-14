import XMLCoder
import Foundation
import LocaleSupport
import TranslationCatalog

struct StringsXml: Decodable, DynamicNodeDecoding {
    enum CodingKeys: String, CodingKey {
        case resources = "string"
    }
    
    var resources: [Resource]
    
    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .element
    }
    
    static func make(contentsOf url: URL) throws -> StringsXml {
        let data = try Data(contentsOf: url)
        return try make(with: data)
    }
    
    static func make(with data: Data) throws -> StringsXml {
        return try XMLDecoder().decode(StringsXml.self, from: data)
    }
}

extension StringsXml {
    func expressions(defaultLanguage: LanguageCode = .default, language: LanguageCode, script: ScriptCode?, region: RegionCode?) -> [Expression] {
        return resources.map { $0.expression(uuid: .zero, defaultLanguage: defaultLanguage, language: language, script: script, region: region) }
    }
}
