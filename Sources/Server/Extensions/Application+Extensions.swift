import Vapor

extension Application {
    static let baseURL = Environment.get("BASE_URL") ?? "https://localhost:8080"
}
