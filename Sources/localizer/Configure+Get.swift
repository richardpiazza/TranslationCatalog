import ArgumentParser
import Foundation

extension Configure {
    struct Get: AsyncParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "get",
            abstract: "Gets configuration parameters.",
            usage: nil,
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        func run() async throws {
            print(Configuration.`default`.description)
        }
    }
}
