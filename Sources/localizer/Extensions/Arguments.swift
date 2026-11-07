import ArgumentParser
import Foundation
import LocaleSupport
import TranslationCatalog
import TranslationCatalogIO

extension Locale: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        let locale = Locale(identifier: argument)
        guard locale.language.languageCode?.isISOLanguage == true else {
            return nil
        }

        self = locale
    }
}

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

extension DefaultValueIndicator: @retroactive ExpressibleByArgument {}

extension TranslationState: ExpressibleByArgument {
    public init?(argument: String) {
        guard let knownState = TranslationState.allCases.first(where: { $0.rawValue == argument }) else {
            return nil
        }

        self = knownState
    }
}
