import ArgumentParser
import Foundation

struct Configure: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "configure",
        abstract: "Displays or alters the command configuration details.",
        version: "1.0.0",
        subcommands: [
            Get.self,
            Set.self
        ],
        defaultSubcommand: Get.self,
        helpNames: .shortAndLong
    )
}
