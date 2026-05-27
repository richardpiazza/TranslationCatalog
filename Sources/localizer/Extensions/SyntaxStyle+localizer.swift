import ArgumentParser
import Foundation
import TranslationCatalogIO

extension SyntaxStyle: ExpressibleByArgument {
    var argument: String {
        switch self {
        case .localeSupport: "locale-support"
        case .swiftUI: "swift-ui"
        }
    }

    public init?(argument: String) {
        guard let style = SyntaxStyle.allCases.first(where: { $0.argument.caseInsensitiveCompare(argument) == .orderedSame }) else {
            return nil
        }

        self = style
    }
}
