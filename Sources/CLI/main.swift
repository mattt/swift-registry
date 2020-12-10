import ArgumentParser
import Foundation
import CryptoKit
import PackageRegistry
import Logging

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

    @Option(name: [.customLong("log")], help: "")
    var logLevel: Logger.Level = .debug
}

RegistryCommand.main()
