import Foundation

public struct Package {
    public let url: URL
    public let name: String

    public init?(_ identifier: String) {
        guard let identifier = identifier.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty?.prefixed(by: "https://"),
              let url = URL(string: identifier), url.host != nil
        else { return nil }

        self.init(url)
    }

    public init?(_ url: URL) {
        guard url.scheme == "https" else { return nil }
        guard let name = url.lastPathComponent.nonEmpty ?? url.host else { return nil }

        self.url = url
        self.name = name
    }

    init?(tagName: String) {
        var components = tagName.split(separator: "/")
        components.removeLast()

        self.init(components.joined(separator: "/"))
    }

    private init(_ package: Package) {
        self.url = package.url
        self.name = package.name
    }

    static func isValidManifestFile(_ fileName: String) -> Bool {
        let pattern = #"\APackage(@swift-(\d+)(?:\.(\d+)){0,2})?.swift\z"#
        return fileName.range(of: pattern, options: .regularExpression) != nil
    }

    var directoryPath: String {
        switch name.count {
        case let count where (1...3).contains(count):
            return "\(count)/\(self)".lowercased()
        default:
            let firstComponent = name.prefix(2)
            let secondComponent = name.prefix(4).suffix(2)
            return "\(firstComponent)/\(secondComponent)/\(self)".lowercased()
        }
    }
}

// MARK: - Equatable & Comparable

extension Package: Equatable, Comparable {
    private func compare(to other: Package) -> ComparisonResult {
        url.absoluteString.precomposedStringWithCanonicalMapping.caseInsensitiveCompare(other.url.absoluteString.precomposedStringWithCanonicalMapping)
    }

    public static func == (lhs: Package, rhs: Package) -> Bool {
        lhs.compare(to: rhs) == .orderedSame
    }

    public static func < (lhs: Package, rhs: Package) -> Bool {
        lhs.compare(to: rhs) == .orderedAscending
    }

    public static func > (lhs: Package, rhs: Package) -> Bool {
        lhs.compare(to: rhs) == .orderedDescending
    }
}

// MARK: - Hashable

extension Package: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

// MARK: - CustomStringConvertible

extension Package: CustomStringConvertible {
    public var description: String {
        [url.host, url.path].compactMap { $0 }.joined()
    }
}

// MARK: - LosslessStringConvertible

extension Package: LosslessStringConvertible {}

// MARK: - ExpressibleByStringLiteral

extension Package: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)!
    }
}

// MARK: - Encodable

extension Package: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(url)
    }
}

// MARK: - Decodable

extension Package: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let url = try container.decode(URL.self)
        guard let package = Package(url) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "invalid url")
        }

        self.init(package)
    }
}

// MARK: -

fileprivate extension StringProtocol {
    func prefixed(by prefix: String) -> String {
        return starts(with: prefix) ? String(self) : prefix + self
    }

    var nonEmpty: Self? {
        self.isEmpty ? nil : self
    }
}
