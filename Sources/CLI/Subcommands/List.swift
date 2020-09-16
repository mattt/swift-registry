import ArgumentParser
import PackageRegistry
import Foundation

extension RegistryCommand {
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "list",
            abstract: "Show all published package releases."
        )

        @OptionGroup
        var options: Options

        mutating func run() throws {
            let registry = try Registry.open(at: URL(fileURLWithPath: options.indexPath))
            let releases = try Dictionary(grouping: registry.releases(), by: \.package)
            for package in releases.keys.sorted() {
                let versions = releases[package]?.map { $0.version }.sorted().map(\.description) ?? []
                print("\(package) - \(versions.joined(separator: ", "))")
            }
        }
    }
}
