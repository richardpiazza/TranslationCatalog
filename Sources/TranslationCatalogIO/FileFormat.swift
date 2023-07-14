/// Known/handled file types of expression/translation lists.
public enum FileFormat: String, CaseIterable {
    /// Android-compatible XML format
    case androidXML = "xml"
    /// Apple-compatible `.strings` format
    case appleStrings = "strings"
    /// Generic json key/value object
    case json = "json"
    
    public init?(fileExtension extension: String) {
        if let format = FileFormat(rawValue: `extension`.lowercased()) {
            self = format
        } else {
            return nil
        }
    }
    
    @available(*, deprecated, renamed: "androidXML")
    public static var android: FileFormat { androidXML }
    @available(*, deprecated, renamed: "appleStrings")
    public static var apple: FileFormat { appleStrings }
}
