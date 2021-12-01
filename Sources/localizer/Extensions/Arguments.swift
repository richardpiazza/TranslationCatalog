import Foundation
import LocaleSupport
import ArgumentParser

extension LanguageCode: ExpressibleByArgument {}
extension RegionCode: ExpressibleByArgument {}
extension ScriptCode: ExpressibleByArgument {}
extension UUID: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(uuidString: argument)
    }
}
