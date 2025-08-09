import ArgumentParser
import Foundation

#if hasFeature(RetroactiveAttribute)
extension Locale.LanguageCode: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        guard Locale.LanguageCode.allCases.contains(where: { $0.identifier == argument }) else {
            return nil
        }

        self = Locale.LanguageCode(argument)
    }
}

extension Locale.Region: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        guard Locale.Region.allCases.contains(where: { $0.identifier == argument }) else {
            return nil
        }

        self = Locale.Region(argument)
    }
}

extension Locale.Script: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        guard Locale.Script.allCases.contains(where: { $0.identifier == argument }) else {
            return nil
        }

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
