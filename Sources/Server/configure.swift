import Vapor
import Git
import PackageRegistry

public func configure(_ app: Application, with registry: Registry) throws {
    app.middleware = Middlewares()
    app.middleware.use(ContentVersionMiddleware())
    app.middleware.use(ContentNegotiationMiddleware())
    app.middleware.use(ProblemDetailsMiddleware())
    app.middleware.use(EndpointsMiddleware(registry: registry))
}
