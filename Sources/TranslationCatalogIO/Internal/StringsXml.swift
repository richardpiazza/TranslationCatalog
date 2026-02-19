import Foundation
import TranslationCatalog
import XMLCoder

struct StringsXml: Codable, DynamicNodeDecoding, DynamicNodeEncoding {
    enum CodingKeys: String, CodingKey {
        case resources = "string"
    }

    var resources: [Resource]

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        .element
    }
    
    static func nodeEncoding(for key: any CodingKey) -> XMLEncoder.NodeEncoding {
        .element
    }

    static func make(contentsOf url: URL) throws -> StringsXml {
        let data = try Data(contentsOf: url)
        return try make(with: data)
    }

    static func make(with data: Data) throws -> StringsXml {
        try XMLDecoder().decode(StringsXml.self, from: data)
    }
    
    func encoded() throws -> Data {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        encoder.prettyPrintIndentation = .spaces(2)
        return try encoder.encode(
            self,
            withRootKey: "resources",
            header: XMLHeader(
                version: 1.0,
                encoding: "UTF-8"
            )
        )
    }
}

extension StringsXml {
    func expressions(
        defaultLanguage: Locale.LanguageCode = .default,
        language: Locale.LanguageCode,
        script: Locale.Script?,
        region: Locale.Region?
    ) -> [TranslationCatalog.Expression] {
        resources.map {
            $0.expression(
                uuid: .zero,
                defaultLanguage: defaultLanguage,
                language: language,
                script: script,
                region: region
            )
        }
    }
}
