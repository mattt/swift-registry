import ArgumentParser
import Foundation
import Server
import Vapor
import PackageRegistry
import Logging

extension RegistryCommand {
    struct Serve: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "serve",
            abstract: "Runs the registry web service locally."
        )

        @OptionGroup
        var options: Options

        mutating func run() throws {
            var env = Environment(name: "development", arguments: ["vapor", "--log", "\(options.logLevel)"])
            try LoggingSystem.bootstrap(from: &env)

            let app = Application(env)
            defer { app.shutdown() }

            let url = URL(fileURLWithPath: options.indexPath)
            let registry = try (try? Registry.open(at: url)) ?? (try Registry.create(at: url))

            try configure(app, with: registry)
            try app.run()
        }
    }
}
