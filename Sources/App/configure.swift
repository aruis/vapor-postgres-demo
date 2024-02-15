import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(HTTPLoggingMiddleware())
    
    app.databases.use(.postgres(configuration: .init(hostname: "127.0.0.1", port: 54322, username: "postgres", password: "vertxbench",database: "vertxbench", tls: .disable) ,maxConnectionsPerEventLoop: 1), as: .psql)
    
    app.http.server.configuration.port = 3020
    
    // register routes
    try await routes(app)
}
