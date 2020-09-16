public struct Release: Hashable, Codable {
    public let package: Package
    public let version: Version

    public init(package: Package, version: Version) {
        self.package = package
        self.version = version
    }

    init?(tagName: String) {
        var components = tagName.split(separator: "/")

        guard let version = Version(String(components.removeLast())),
              let package = Package(components.joined(separator: "/"))
        else { return nil }

        self.init(package: package, version: version)
    }

    var tagName: String {
        "\(package)/\(version)".lowercased()
    }

    var archivePath: String {
        package.directoryPath + "/\(version).zip"
    }
}

// MARK: - Comparable

extension Release: Comparable {
    public static func < (lhs: Release, rhs: Release) -> Bool {
        return (lhs.package, lhs.version) < (rhs.package, rhs.version)
    }
}
