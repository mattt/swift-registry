import Vapor
import Foundation
import PackageRegistry

extension HTTPMediaType {
    static let swift = HTTPMediaType(type: "text", subType: "x-swift")
    static let problemDetails = HTTPMediaType(type: "application", subType: "problem+json")
}

func + (lhs: HTTPMediaType, rhs: String) -> HTTPMediaType {
    return HTTPMediaType(type: lhs.type, subType: lhs.subType.prefix(while: { $0 != "+" }) + "+\(rhs)")
}

// MARK: -

extension Registry {
    static let v1 = HTTPMediaType(type: "application", subType: "vnd.swift.registry.v1")
}

// MARK: -

extension Array where Element == HTTPMediaTypePreference {
    var hasValidAPIVersion: Bool {
        contains(where: { preference in
            preference.mediaType.description.matches(#"application/vnd\.swift\.registry(\.v1(\+(json|swift|zip))?)?"#)
        })
    }

    func prefers(_ mediaType: HTTPMediaType) -> Bool {
        contains(where: { preference in
            preference.mediaType == mediaType
        })
    }
}

// MARK: -

fileprivate extension StringProtocol {
    func matches(_ pattern: String) -> Bool {
        range(of: pattern, options: .regularExpression) != nil
    }
}
