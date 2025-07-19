import LocaleSupport
import TranslationCatalog

extension StringCatalog {
    struct Language: Hashable, Sendable, LocaleRepresentable {
        let languageCode: LanguageCode
        let regionCode: RegionCode?
        let scriptCode: ScriptCode?
        
        var description: String { localeIdentifier }
    }
}

extension StringCatalog.Language: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        var components = rawValue.split(separator: "-")
        
        guard !components.isEmpty else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Empty raw value.")
            throw DecodingError.typeMismatch(LocaleRepresentable.self, context)
        }
        
        let language = components.removeFirst()
        guard let languageCode = LanguageCode.allCases.first(where: { $0.rawValue.compare(language, options: .caseInsensitive) == .orderedSame }) else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "LanguageCode '\(language)' Not Found.")
            throw DecodingError.typeMismatch(LanguageCode.self, context)
        }
        
        self.languageCode = languageCode
        
        guard !components.isEmpty else {
            regionCode = nil
            scriptCode = nil
            return
        }
        
        let regionOrScript = components.removeFirst()
        if let regionCode = RegionCode.allCases.first(where: { $0.rawValue.compare(regionOrScript, options: .caseInsensitive) == .orderedSame }) {
            self.regionCode = regionCode
        } else if let scriptCode = ScriptCode.allCases.first(where: { $0.rawValue.compare(regionOrScript, options: .caseInsensitive) == .orderedSame }) {
            regionCode = nil
            self.scriptCode = scriptCode
            return
        } else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Value '\(regionOrScript)' did not match any known Region/Script code.")
            throw DecodingError.dataCorrupted(context)
        }
        
        guard !components.isEmpty else {
            self.scriptCode = nil
            return
        }
        
        let script = components.removeFirst()
        guard let scriptCode = ScriptCode.allCases.first(where: { $0.rawValue.compare(script, options: .caseInsensitive) == .orderedSame }) else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "ScriptCode '\(script)' Not Found.")
            throw DecodingError.typeMismatch(LanguageCode.self, context)
        }
        
        self.scriptCode = scriptCode
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(localeIdentifier)
    }
}
