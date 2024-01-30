import Vapor
import FluentSQL


func routes(_ app: Application) async throws {
    
    app.get("api","testDB") { req async throws -> String in
           if let sql = req.db as? SQLDatabase {
               // The underlying database driver is SQL.
               if let res = try await sql.raw("SELECT 1 AS value").first(decoding: SimpleResult.self)?.value {
                   return "\(res)"
               }else {
                   return ""
               }                                   
           } else {
               // Handle the case where the database is not SQL.
               throw Abort(.internalServerError, reason: "Database is not SQL")
           }
       }
    
    
    app.get("hello") { req async -> String in
        "Hello, world!"
    }
}

struct SimpleResult: Codable {
    let value: Int
}

struct HTTPLoggingMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // 记录请求开始的时间
        let start = Date()

        // 继续处理请求
        let response = try await next.respond(to: request)

        // 获取请求结束的时间
//        let duration = Date().timeIntervalSince(start)

        // 提取请求信息
        let method = request.method.string
        let uri = request.url.string
        let host = request.headers.first(name: .host) ?? ""
        let httpVersion = "\(request.version.major).\(request.version.minor)"
        let referrer = request.headers.first(name: .referer) ?? ""
        let userAgent = request.headers.first(name: .userAgent) ?? ""

        
        // 异步插入日志到数据库
        if let sql = request.db as? SQLDatabase {
            do {
                let _ = try await sql.raw("""
                    INSERT INTO log_http (t_create, v_method, v_uri, v_host, v_http_version, v_referrer, v_user_agent)
                    VALUES (NOW(), \(bind: method), \(bind: uri), \(bind: host), \(bind: httpVersion), \(bind: referrer), \(bind: userAgent));
                    """).run()
            } catch {
                // 输出错误到控制台
                print(String(reflecting: error))
            }
        }

        return response
    }
}
