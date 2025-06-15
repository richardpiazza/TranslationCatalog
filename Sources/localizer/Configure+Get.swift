import ArgumentParser
import Foundation

extension Configure {
    struct Get: AsyncParsableCommand {
        
        static let configuration = CommandConfiguration(
            commandName: "get",
            abstract: "Gets configuration parameters.",
            version: "1.0.0",
            helpNames: .shortAndLong
        )
        
        func run() async throws {
            print(Configuration.`default`.description)
        }
    }
}
