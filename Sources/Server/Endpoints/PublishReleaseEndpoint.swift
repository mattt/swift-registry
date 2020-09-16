import Vapor
import Foundation
import PackageRegistry
import AnyCodable

let maximumMetadataContentLength = 1024 * 1024

struct PublishReleaseEndpoint: Responder {
    var registry: Registry
    var package: Package
    var version: Version

    func respond(to request: Request) -> EventLoopFuture<Response> {
        request.eventLoop.tryFuture {
            let status: HTTPStatus

            let release: Release
            if let existing = try registry.releases(for: package).first(where: { $0.version == version }) {
                release = existing
                status = .noContent
            } else {
                release = try registry.publish(version: version, of: package)
                status = .created
            }

            if request.content.contentType == .json {
                guard (request.body.data?.readableBytes ?? 0) <= maximumMetadataContentLength else {
                    throw Abort(.payloadTooLarge, reason: "metadata exceeds limit of \(maximumMetadataContentLength) bytes")
                }

                guard let metadata = try? request.content.decode([String: AnyCodable].self) else {
                    throw Abort(.badRequest, reason: "invalid JSON")
                }

                try registry.update(metadata: metadata, for: release)
            }

            return Response(status: status, version: request.version, headers: [:], body: .empty)
        }
    }
}
