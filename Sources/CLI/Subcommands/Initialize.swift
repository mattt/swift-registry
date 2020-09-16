import Foundation
import ArgumentParser
import PackageRegistry

extension RegistryCommand {
    struct Initialize: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "init",
            abstract: "Initializes a new registry at the specified path."
        )

        @OptionGroup
        var options: Options

        @Flag
        var force: Bool = false

        @Option(help: "")
        var name: String?

        @Option(help: "")
        var email: String?

        @Option(help: "")
        var signingKey: String?

        mutating func validate() throws {
            guard (name == nil) == (email == nil) else {
                throw ValidationError("Please specify both name and email, if any")
            }
        }

        mutating func run() throws {
            var configuration: [String: String] = [:]
            if let name = name, let email = email {
                configuration["user.name"] = name
                configuration["user.email"] = email
            }

            if let signingKey = signingKey {
                configuration["user.signingkey"] = signingKey
                configuration["commit.gpgsign"] = "true"
            }

            try Registry.create(at: URL(fileURLWithPath: options.indexPath), with: configuration)
        }
    }
}
