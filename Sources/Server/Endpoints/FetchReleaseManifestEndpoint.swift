import Vapor
import Foundation
import PackageRegistry

struct FetchReleaseManifestEndpoint: Responder {
    var registry: Registry
    var release: Release
    var swiftVersion: String?

    func respond(to request: Request) -> EventLoopFuture<Response> {
        guard (try? registry.releases(for: release.package).contains(release)) == true else {
            return request.eventLoop.makeFailedFuture(Abort(.notFound))
        }

        let promise = request.eventLoop.makePromise(of: String.self)

        registry.manifest(for: release, swiftVersion: swiftVersion) { result in
            promise.completeWith(result)
        }

        return promise.futureResult.flatMapThrowing { manifest in
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
