import Vapor
import Git
import Foundation
import QueuesRedisDriver
import PackageRegistry

public func configure(_ app: Application, with registry: Registry) throws {
    app.middleware = Middlewares()
    app.middleware.use(ContentVersionMiddleware())
    app.middleware.use(ContentNegotiationMiddleware())
    app.middleware.use(ProblemDetailsMiddleware())
    app.middleware.use(EndpointsMiddleware(registry: registry))

//    try app.queues.use(.redis(url: "redis://127.0.0.1:6379"))
//    try app.queues.startInProcessJobs(on: .default)
//    app.queues.add(PublishJob())
}
