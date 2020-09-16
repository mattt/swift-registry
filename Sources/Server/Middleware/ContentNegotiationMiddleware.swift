import Vapor
import Foundation
import PackageRegistry

struct ContentNegotiationMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if let index = request.url.path.lastIndex(of: ".") {
            switch request.url.path.suffix(from: index) {
            case ".json", ".zip":
                request.url.path = String(request.url.path.prefix(upTo: index))
            default:
                break
            }
        }

        guard request.headers.accept.hasValidAPIVersion else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return next.respond(to: request)
    }
}
