import XMLCoder
import Foundation
import LocaleSupport
import TranslationCatalog

public struct StringsXml: Decodable, DynamicNodeDecoding {
    enum CodingKeys: String, CodingKey {
        case resources = "string"
    }
    
    public var resources: [Resource]
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return .element
    }
    
    public static func make(contentsOf url: URL) throws -> StringsXml {
        let data = try Data(contentsOf: url)
        return try make(with: data)
    }
    
    public static func make(with data: Data) throws -> StringsXml {
        return try XMLDecoder().decode(StringsXml.self, from: data)
    }
}

public extension StringsXml {
    func expressions(defaultLanguage: LanguageCode = .default, language: LanguageCode, script: ScriptCode?, region: RegionCode?) -> [Expression] {
        return resources.map { $0.expression(uuid: .zero, defaultLanguage: defaultLanguage, language: language, script: script, region: region) }
    }
}
