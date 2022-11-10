import ArgumentParser
import Foundation

struct Configure: ParsableCommand {
    
    static var configuration: CommandConfiguration = .init(
        commandName: "configure",
        abstract: "Displays or alters the command configuration details.",
        usage: nil,
        discussion: "",
        version: "1.0.0",
        shouldDisplay: true,
        subcommands: [
            Get.self,
            Set.self
        ],
        defaultSubcommand: Get.self,
        helpNames: .shortAndLong
    )
}
