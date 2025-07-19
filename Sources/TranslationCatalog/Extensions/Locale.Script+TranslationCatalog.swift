import Foundation

public extension Locale.Script {
    init(matching knownIdentifier: String) throws {
        let script = Locale.Script(knownIdentifier)
        guard Self.allCases.contains(script) else {
            throw LocaleError.script(knownIdentifier)
        }

        self = script
    }
}

#if hasFeature(RetroactiveAttribute)
extension Locale.Script: @retroactive CaseIterable {
    public static let allCases: [Locale.Script] = [
        .adlam,
        .arabic,
        .arabicNastaliq,
        .armenian,
        .bangla,
        .cherokee,
        .cyrillic,
        .devanagari,
        .ethiopic,
        .georgian,
        .greek,
        .gujarati,
        .gurmukhi,
        .hanifiRohingya,
        .hanSimplified,
        .hanTraditional,
        .hebrew,
        .hiragana,
        .japanese,
        .kannada,
        .katakana,
        .khmer,
        .korean,
        .lao,
        .latin,
        .malayalam,
        .meiteiMayek,
        .myanmar,
        .odia,
        .olChiki,
        .sinhala,
        .syriac,
        .tamil,
        .telugu,
        .thaana,
        .thai,
        .tibetan,
    ]
}
#else
extension Locale.Script: CaseIterable {
    public static let allCases: [Locale.Script] = [
        .adlam,
        .arabic,
        .arabicNastaliq,
        .armenian,
        .bangla,
        .cherokee,
        .cyrillic,
        .devanagari,
        .ethiopic,
        .georgian,
        .greek,
        .gujarati,
        .gurmukhi,
        .hanifiRohingya,
        .hanSimplified,
        .hanTraditional,
        .hebrew,
        .hiragana,
        .japanese,
        .kannada,
        .katakana,
        .khmer,
        .korean,
        .lao,
        .latin,
        .malayalam,
        .meiteiMayek,
        .myanmar,
        .odia,
        .olChiki,
        .sinhala,
        .syriac,
        .tamil,
        .telugu,
        .thaana,
        .thai,
        .tibetan,
    ]
}
#endif
