import Foundation
import LocaleSupport

public protocol LocaleRepresentable {
    var languageCode: LanguageCode { get }
    var scriptCode: ScriptCode? { get }
    var regionCode: RegionCode? { get }
}

public extension LocaleRepresentable {
    var localeIdentifier: Locale.Identifier {
        var output = languageCode.rawValue
        if let scriptCode = self.scriptCode {
            output += "-\(scriptCode.rawValue)"
        }
        if let regionCode = self.regionCode {
            output += "_\(regionCode.rawValue)"
        }
        return output
    }
}
