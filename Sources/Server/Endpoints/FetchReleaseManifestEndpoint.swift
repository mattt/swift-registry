import Vapor
import Foundation
import PackageRegistry

struct FetchReleaseManifestEndpoint: Responder {
    var registry: Registry
    var release: Release
    var swiftVersion: String?

    func respond(to request: Request) -> EventLoopFuture<Response> {
        request.eventLoop.tryFuture {
            guard try registry.releases(for: release.package).contains(release) else { throw Abort(.notFound) }
            guard let manifest = registry.manifest(for: release, swiftVersion: swiftVersion) else {
                throw Abort(.seeOther, headers: ["Location": "/\(release.package)/\(release.version)/Package.swift"])
            }

            var headers: HTTPHeaders = [:]
            headers.contentType = .swift
            if let swiftVersion = swiftVersion {
                headers.contentDisposition = .init(.attachment, filename: "Package@swift-\(swiftVersion).swift")
            } else {
                headers.contentDisposition = .init(.attachment, filename: "Package.swift")
            }

            return Response(status: .ok, version: request.version, headers: headers, body: .init(string: manifest))
        }
    }
}
