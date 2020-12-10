import Vapor
import Foundation

struct Problem: Error {
    var type: String?
    var status: HTTPResponseStatus
    var locale: Locale? = .current
    var title: String?
    var detail: String?
    var instance: String?

    init(_ error: Error) {
        switch error {
        case let problem as Problem:
            self.type = problem.type
            self.status = problem.status
            self.title = problem.title
            self.detail = problem.detail
            self.instance = problem.instance
        case let abort as AbortError:
            self.status = abort.status
            self.title = abort.reason
        default:
            self.status = .internalServerError
            self.detail = error.localizedDescription
        }
    }
}

// MARK: - DebuggableError

extension Problem: DebuggableError {
    var identifier: String {
        [type, title, instance].compactMap { $0 }.joined(separator: " - ")
    }

    var reason: String {
        detail ?? title ?? "Unknown"
    }
}

// MARK: - ResponseEncodable

extension Problem: ResponseEncodable {
    func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        var headers: HTTPHeaders = [:]
        headers.contentType = .problemDetails
        if let languageCode = locale?.languageCode {
            headers.add(name: .contentLanguage, value: languageCode)
        }

        var body: [String: String] = [:]

        body["type"] = type
        body["title"] = title ?? HTTPURLResponse.localizedString(forStatusCode: numericCast(status.code))
        body["detail"] = detail
        body["instance"] = instance

        return body.encodeResponse(status: status, headers: headers, for: request)
    }
}
