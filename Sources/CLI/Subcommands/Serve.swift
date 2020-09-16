import ArgumentParser
import Foundation
import Server
import Vapor
import PackageRegistry

extension RegistryCommand {
    struct Serve: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "serve",
            abstract: "Runs the registry web service locally."
        )

        @OptionGroup
        var options: Options

        mutating func run() throws {
            let env = Environment(name: "development", arguments: ["vapor"])
            let app = Application(env)
            defer { app.shutdown() }

            let url = URL(fileURLWithPath: options.indexPath)
            let registry = try (try? Registry.open(at: url)) ?? (try Registry.create(at: url))

            try configure(app, with: registry)
            try app.run()
        }
    }
}
