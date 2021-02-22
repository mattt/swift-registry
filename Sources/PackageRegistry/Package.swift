import Foundation

public struct Package {
    public let scope: String
    public let name: String

    public init?(_ description: String) {
        guard !description.isEmpty,
              let separatorIndex = description.firstIndex(of: "/"),
              separatorIndex != description.endIndex
        else {
            return nil
        }

        do {
            let scope = description.prefix(upTo: separatorIndex)
            guard scope.count <= 40,
                  case let (initial, rest)? = scope.headAndTail,
                  initial == "@",
                  case let (head, tail)? = rest.headAndTail,
                  head.isAlphanumeric,
                  tail.allSatisfy({ $0.isAlphanumeric || $0 == "-" }),
                  head != "-", tail.last != "-",
                  !scope.containsContiguousHyphens
            else {
                return nil
            }
            self.scope = String(scope)
        }

        do {
            let name = description.suffix(from: description.index(after: separatorIndex))
            let unicodeScalars = name.unicodeScalars
            guard name.count <= 128,
                  case let (head, tail)? = unicodeScalars.headAndTail,
                  head.properties.isXIDStart,
                  tail.allSatisfy({ $0.properties.isXIDContinue })
            else {
                return nil
            }
            self.name = String(name)
        }
    }

    init?(tagName: String) {
        var components = tagName.split(separator: "/")
        components.removeLast()

        self.init(components.joined(separator: "/"))
    }

    private init(package: Package) {
        self.scope = package.scope
        self.name = package.name
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

extension Package {
    public static func isValidManifestFile(_ fileName: String) -> Bool {
        let pattern = #"\APackage(@swift-(\d+)(?:\.(\d+)){0,2})?.swift\z"#
        return fileName.range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - Equatable & Comparable

extension Package: Equatable, Comparable {
    private static func compare(_ lhs: Package, _ rhs: Package) -> ComparisonResult {
        let lhs = lhs.description.precomposedStringWithCompatibilityMapping
        let rhs = rhs.description.precomposedStringWithCompatibilityMapping
        return lhs.compare(rhs, options: [.caseInsensitive, .diacriticInsensitive])
    }

    public static func == (lhs: Package, rhs: Package) -> Bool {
        compare(lhs, rhs) == .orderedSame
    }

    public static func < (lhs: Package, rhs: Package) -> Bool {
        compare(lhs, rhs) == .orderedAscending
    }

    public static func > (lhs: Package, rhs: Package) -> Bool {
        compare(lhs, rhs) == .orderedDescending
    }
}

// MARK: - Hashable

extension Package: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(scope.lowercased())
        hasher.combine(name.lowercased().precomposedStringWithCompatibilityMapping)
    }
}

// MARK: - CustomStringConvertible

extension Package: CustomStringConvertible {
    public var description: String {
        "\(scope)/\(name)"
    }
}

// MARK: - LosslessStringConvertible

extension Package: LosslessStringConvertible {}

// MARK: - Encodable

extension Package: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let identifier = self.description
        try container.encode(identifier)
    }
}

// MARK: - Decodable

extension Package: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)
        guard let package = Package(identifier) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "invalid identifier")
        }

        self.init(package: package)
    }
}

// MARK: -


fileprivate extension Collection {
    var headAndTail: (head: Element, tail: SubSequence)? {
        guard let head = first else { return nil }
        return (head, dropFirst())
    }
}

fileprivate extension StringProtocol {
    var containsContiguousHyphens: Bool {
        guard var previous = first else { return false }
        for character in suffix(from: startIndex) {
            defer { previous = character }
            if character == "-" && previous == "-" {
                return true
            }
        }

        return false
    }
}

fileprivate extension Character {
    var isAlphanumeric: Bool {
        isASCII && (isLetter || isNumber)
    }
}
