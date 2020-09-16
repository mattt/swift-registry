import Vapor
import Foundation
import PackageRegistry

struct ContentVersionMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        next.respond(to: request).map { response in
            response.headers.replaceOrAdd(name: "Content-Version", value: "1")
            return response
        }
    }
}
