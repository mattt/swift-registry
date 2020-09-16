import Vapor
import Foundation
import PackageRegistry

struct ListReleasesEndpoint: Responder {
    var registry: Registry
    var package: Package

    func respond(to request: Request) -> EventLoopFuture<Response> {
        request.eventLoop.tryFuture {
            let releases = try registry.releases(for: package)
            guard !releases.isEmpty else { throw Abort(.notFound) }

            let payload = [
                "releases": [String: [String: String]](uniqueKeysWithValues: releases.compactMap { release in
                    guard let url = request.baseURL?.appendingPathComponent("\(release.package)").appendingPathComponent("\(release.version)") else { return nil }
                    return ("\(release.version)", ["url": url.absoluteString])
                })
            ]

            let data = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)

            var headers: HTTPHeaders = [:]
            headers.contentType = .json

            return Response(status: .ok, version: request.version, headers: headers, body: .init(data: data))
        }
    }
}

// MARK: -

fileprivate extension Request {
    var baseURL: URL? {
        var components = URLComponents()
        components.scheme = application.environment.isRelease ? "https" : "http"
        components.host = application.http.server.configuration.hostname
        components.port = application.environment.isRelease && application.http.server.configuration.port == 443 ? nil : application.http.server.configuration.port
        return components.url
    }
}
