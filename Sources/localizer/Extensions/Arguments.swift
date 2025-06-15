import ArgumentParser
import Foundation
import LocaleSupport

#if hasFeature(RetroactiveAttribute)
extension LanguageCode: @retroactive ExpressibleByArgument {}
extension RegionCode: @retroactive ExpressibleByArgument {}
extension ScriptCode: @retroactive ExpressibleByArgument {}
extension UUID: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self.init(uuidString: argument)
    }
}
#else
extension LanguageCode: ExpressibleByArgument {}
extension RegionCode: ExpressibleByArgument {}
extension ScriptCode: ExpressibleByArgument {}
extension UUID: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(uuidString: argument)
    }
}
#endif
