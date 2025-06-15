import ArgumentParser
import TranslationCatalogIO

extension FileFormat: ExpressibleByArgument {
    var argument: String {
        switch self {
        case .androidXML: "android-xml"
        case .appleStrings: "apple-strings"
        case .json: "json"
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
