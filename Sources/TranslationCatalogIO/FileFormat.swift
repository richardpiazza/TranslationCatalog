/// Known/handled file types of expression/translation lists.
public enum FileFormat: CaseIterable {
    /// Android-compatible XML format
    case androidXML
    /// Apple-compatible `.strings` format
    case appleStrings
    /// Generic json key/value object
    case json

    public init?(fileExtension extension: String) {
        if let format = FileFormat.allCases.first(where: { $0.fileExtension.caseInsensitiveCompare(`extension`) == .orderedSame }) {
            self = format
        } else {
            return nil
        }
    }

    public var fileExtension: String {
        switch self {
        case .androidXML: "xml"
        case .appleStrings: "strings"
        case .json: "json"
        }
    }
}
