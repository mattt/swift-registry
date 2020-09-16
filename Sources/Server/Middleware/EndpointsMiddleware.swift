import Vapor
import Foundation
import PackageRegistry

struct EndpointsMiddleware: Middleware {
    public let registry: Registry

    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        var components = request.url.path.split(separator: "/", omittingEmptySubsequences: true)

        let manifest = components.popLast(if: "Package.swift") != nil
        let version = components.popLast { Version(String($0)) }
        let package = Package(components.joined(separator: "/"))

        let endpoint: Responder
        switch (request.method, package, version) {
        case let (.GET, package?, nil):
            endpoint = ListReleasesEndpoint(registry: registry, package: package)
        case let (.GET, package?, version?):
            let release = Release(package: package, version: version)
            if manifest {
                let swiftVersion = request.url.queryItems?.first(where: { $0.name == "swift-version" })?.value
                endpoint = FetchReleaseManifestEndpoint(registry: registry, release: release, swiftVersion: swiftVersion)
            } else if request.headers.accept.prefers(Registry.v1 + "zip") {
                endpoint = DownloadReleaseSourceArchiveEndpoint(registry: registry, release: release)
            } else {
                endpoint = FetchReleaseMetadataEndpoint(registry: registry, release: release)
            }
        case let (.PUT, package?, version?):
            endpoint = PublishReleaseEndpoint(registry: registry, package: package, version: version)
        default:
            return next.respond(to: request)
        }

        return endpoint.respond(to: request)
    }
}

// MARK: -

fileprivate func ~= (pattern: HTTPMethod, value: HTTPMethod) -> Bool {
    return value == pattern || (pattern == .GET && value == .HEAD)
}

fileprivate extension Array where Element: StringProtocol {
    @discardableResult
    mutating func popLast(if element: String) -> String? {
        popLast { $0 == element }?.description
    }

    mutating func popLast(where condition: (Element) -> Bool) -> String? {
        guard let last = last, condition(last) else { return nil }
        _ = popLast()
        return String(last)
    }

    mutating func popLast<T>(when transform: (Element) -> T?) -> T? {
        guard let last = last else { return nil }
        guard let mapped = transform(last) else { return nil }
        _ = popLast()
        return mapped
    }
}

fileprivate extension URI {
    var queryItems: [URLQueryItem]? {
        var components = URLComponents()
        components.query = self.query
        return components.queryItems
    }
}
