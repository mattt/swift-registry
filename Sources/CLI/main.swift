import ArgumentParser
import Foundation
import CryptoKit
import PackageRegistry

struct RegistryCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "",
        version: "1.0.0",
        subcommands: [
            Initialize.self,
            List.self,
            Publish.self,
            Serve.self
        ]
    )
}

struct Options: ParsableArguments {
    @Option(name: [.customLong("index")], help: "")
    var indexPath: String
}

RegistryCommand.main()
