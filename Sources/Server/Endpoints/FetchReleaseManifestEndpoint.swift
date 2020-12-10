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

        let promise = request.eventLoop.makePromise(of: Response.self)

        registry.manifest(for: release, swiftVersion: swiftVersion) { result in
            switch result {
            case .success(let manifest):
                var headers: HTTPHeaders = [:]
                headers.contentType = .swift
                if let swiftVersion = swiftVersion {
                    headers.contentDisposition = .init(.attachment, filename: "Package@swift-\(swiftVersion).swift")
                } else {
                    headers.contentDisposition = .init(.attachment, filename: "Package.swift")
                }

                let response = Response(status: .ok, version: request.version, headers: headers, body: .init(string: manifest))

                promise.succeed(response)
            case .failure(_ as PackageRegistry.Error) where swiftVersion != nil:
                var components = request.url.path.split(separator: "/")
                components.removeLast()
                components.append("Package.swift")
                let location = components.joined(separator: "/")

                var headers: HTTPHeaders = [:]
                headers.add(name: .location, value: location)
                let response = Response(status: .seeOther, version: request.version, headers: headers, body: .empty)

                promise.succeed(response)
            case .failure(let error):
                promise.fail(error)
            }
        }

        return promise.futureResult
    }
}
