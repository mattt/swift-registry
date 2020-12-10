import Vapor
import Foundation
import PackageRegistry

struct DownloadReleaseSourceArchiveEndpoint: Responder {
    var registry: Registry
    var release: Release

    func respond(to request: Request) -> EventLoopFuture<Response> {
        request.eventLoop.tryFuture {
            guard try registry.releases(for: release.package).contains(release),
                  let archive = registry.archive(of: release)
            else { throw Abort(.notFound) }

            let archiveURL = registry.indexURL.appendingPathComponent(archive.path)

            let response = request.fileio.streamFile(at: archiveURL.path)
            response.headers.contentType = .zip
            response.headers.contentDisposition = .init(.attachment, filename: "\(release.package.name)-\(release.version)")
            response.headers.add(name: .digest, value: "sha-256=\(archive.checksum)")

            return response
        }
    }
}
