import XCTest

final class LocalizerTests: _LocalizerTestCase {
    
    func testExecute() throws {
        try process.run()
        process.waitUntilExit()
        
        XCTAssertEqual(output, """
        OVERVIEW: Android 'strings.xml' & Apple 'Localizable.strings' utility.

        Default Language Code: en
        Default Region Code: US

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
          configure               Displays or alters the command configuration details.

          See 'localizer help <subcommand>' for detailed help.
        
        """)
    }
}
