import Vapor
import Foundation
import PackageRegistry

struct FetchReleaseMetadataEndpoint: Responder {
    var registry: Registry
    var release: Release

    func respond(to request: Request) -> EventLoopFuture<Response> {
        request.eventLoop.tryFuture {
            guard try registry.releases(for: release.package).contains(release) else { throw Abort(.notFound) }
            let metadata = try registry.metadata(for: release) ?? [:]

            let data = try JSONSerialization.data(withJSONObject: metadata, options: .prettyPrinted)

            var headers: HTTPHeaders = [:]
            headers.contentType = .json

            return Response(status: .ok, version: request.version, headers: headers, body: .init(data: data))
        }
    }
}
