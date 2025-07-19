import ArgumentParser
import Foundation

#if hasFeature(RetroactiveAttribute)
extension Locale.LanguageCode: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self = Locale.LanguageCode(argument)
    }
}

extension Locale.Region: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self = Locale.Region(argument)
    }
}

extension Locale.Script: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self = Locale.Script(argument)
    }
}

extension UUID: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self.init(uuidString: argument)
    }
}
#else
extension Locale.LanguageCode: ExpressibleByArgument {
    public init?(argument: String) {
        self = Locale.LanguageCode(argument)
    }
}

extension Locale.Region: ExpressibleByArgument {
    public init?(argument: String) {
        self = Locale.Region(argument)
    }
}

extension Locale.Script: ExpressibleByArgument {
    public init?(argument: String) {
        self = Locale.Script(argument)
    }
}

extension UUID: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(uuidString: argument)
    }
}
#endif
