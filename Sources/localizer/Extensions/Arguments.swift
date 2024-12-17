import Foundation
import LocaleSupport
import ArgumentParser

extension LanguageCode: @retroactive ExpressibleByArgument {}
extension RegionCode: @retroactive ExpressibleByArgument {}
extension ScriptCode: @retroactive ExpressibleByArgument {}
extension UUID: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self.init(uuidString: argument)
    }
}
