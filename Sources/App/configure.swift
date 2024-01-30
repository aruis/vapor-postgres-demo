import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(HTTPLoggingMiddleware())
    
    app.databases.use(.postgres(
          hostname: "localhost",
          port: 54322,
          username: "postgres",
          password: "vertxbench",
          database: "vertxbench",
          maxConnectionsPerEventLoop:2
      ), as: .psql)
    
    app.http.server.configuration.port = 3020
    
    // register routes
    try await routes(app)
}
