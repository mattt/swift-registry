import ArgumentParser
import PackageRegistry
import Foundation

extension RegistryCommand {
    struct Publish: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "publish",
            abstract: "Creates a new release of a package."
        )

        @OptionGroup
        var options: Options

        @Argument
        var package: Package

        @Argument
        var version: Version

        mutating func run() throws {
            let registry = try Registry.open(at: URL(fileURLWithPath: options.indexPath))
            try registry.publish(version: version, of: package)
            print("Published \(package) \(version)")
        }
    }
}
