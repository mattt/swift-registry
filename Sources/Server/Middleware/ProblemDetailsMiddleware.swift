import Vapor
import Foundation
import PackageRegistry

struct ProblemDetailsMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        next.respond(to: request).flatMapError { error in
            var problem = Problem(error)
            problem.instance = request.logger[metadataKey: "request-id"]?.description

            request.logger.report(error: problem)

            return problem.encodeResponse(for: request)
        }
    }
}
