import XCTest

final class HelpTests: XCTestCase {

    func testNoArguments() throws {
        let process = LocalizerProcess()
        let output = try process.runOutputting()

        XCTAssertEqual(output, """
        OVERVIEW: Utility for interacting with Android 'strings.xml', Apple
        'Localizable.strings', and Web '*.json' localization files.

        Default Language Code: en
        Default Region Code: US
        Default Storage: sqlite

        USAGE: localizer <subcommand>

        OPTIONS:
          --version               Show the version.
          -h, --help              Show help information.

        SUBCOMMANDS:
          preview                 Displays the localizations found in a translation
                                  file.
          catalog                 Interact with the translation catalog.
          import                  Imports a translation file into the catalog.
          export                  Export a translation file using the catalog.
          syntax                  Create a enumerated syntax tree.
          configure               Displays or alters the command configuration details.

          See 'localizer help <subcommand>' for detailed help.

        """)
    }
}
