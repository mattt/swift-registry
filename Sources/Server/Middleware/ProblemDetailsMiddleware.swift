import Vapor
import Foundation
import PackageRegistry

struct ProblemDetailsMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        next.respond(to: request).flatMapError { error in
            Problem(error).encodeResponse(for: request)
        }
    }
}
