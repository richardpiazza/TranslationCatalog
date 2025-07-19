import ArgumentParser
import Foundation

#if hasFeature(RetroactiveAttribute)
extension Locale.LanguageCode: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        guard let languageCode = try? Locale.LanguageCode(matching: argument) else {
            return nil
        }

        self = languageCode
    }
}

extension Locale.Region: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        guard let region = try? Locale.Region(matching: argument) else {
            return nil
        }

        self = region
    }
}

extension Locale.Script: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        guard let script = try? Locale.Script(matching: argument) else {
            return nil
        }

        self = script
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
        guard let languageCode = try? Locale.LanguageCode(matching: argument) else {
            return nil
        }

        self = languageCode
    }
}

extension Locale.Region: ExpressibleByArgument {
    public init?(argument: String) {
        guard let region = try? Locale.Region(matching: argument) else {
            return nil
        }

        self = region
    }
}

extension Locale.Script: ExpressibleByArgument {
    public init?(argument: String) {
        guard let script = try? Locale.Script(matching: argument) else {
            return nil
        }

        self = script
    }
}

extension UUID: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(uuidString: argument)
    }
}
#endif
