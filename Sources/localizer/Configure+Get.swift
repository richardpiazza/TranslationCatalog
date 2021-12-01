import ArgumentParser
import Foundation

extension Configure {
    struct Get: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "get",
            abstract: "Gets configuration parameters.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        func run() throws {
            print(Configuration.`default`.description)
        }
    }
}
