import TranslationCatalogIO
import ArgumentParser

extension FileFormat: ExpressibleByArgument {
    var argument: String {
        switch self {
        case .androidXML: return "android-xml"
        case .appleStrings: return "apple-strings"
        case .json: return "json"
        }
    }
    
    public init?(argument: String) {
        if let format = FileFormat.allCases.first(where: { $0.argument.caseInsensitiveCompare(argument) == .orderedSame }) {
            self = format
        } else if argument.caseInsensitiveCompare("android") == .orderedSame {
            self = .androidXML
        } else if argument.caseInsensitiveCompare("apple") == .orderedSame {
            self = .appleStrings
        } else {
            return nil
        }
    }
}
