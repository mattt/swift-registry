@testable import Server
@testable import PackageRegistry
import XCTVapor

final class FetchReleaseMetadataEndpointTests: EndpointTestCase {
    func testFetchMetadataForAPackageRelease() throws {
        /*
         A client MAY send a `GET` request
         for a URI matching the expression `/{package}/{version}`
         to retrieve metadata about a release.
         A client SHOULD set the `Accept` header with
         the `application/vnd.swift.registry.v1+json` content type,
         and MAY append the `.json` extension to the requested URI.

         ```http
         GET /@mona/LinkedList/1.1.1 HTTP/1.1
         Host: packages.example.com
         Accept: application/vnd.swift.registry.v1+json
         ```
         */
        try app.test(.GET, "@mona/LinkedList/1.1.1",
                     headers: ["Accept": "application/vnd.swift.registry.v1+json"],
                     afterResponse: { response in
                        /*
                        A server SHALL set the `Content-Type` and `Content-Version` header fields
                        with the corresponding content type and API version number of the response.
                        */
                        XCTAssertEqual(response.headers.first(name: "Content-Version"), "1")

                        /*
                        If a release is found for the requested URI,
                        a server SHOULD respond with a status code of `200` (OK)
                        and the `Content-Type` header `application/json`.
                        */
                        XCTAssertEqual(response.status, .ok)
                        XCTAssertEqual(response.headers.contentType, .json)
                     })
    }

    func testFetchMetadataForAnUnknownPackageRelease() throws {
        /*
        If no release is found for the requested URI,
        a server SHOULD respond with a status code of `404` (NOT FOUND).
        */
        try app.test(.GET, "@mona/LinkedList/0.0.0",
                     headers: ["Accept": "application/vnd.swift.registry.v1+json"],
                     afterResponse: { response in
                        XCTAssertEqual(response.status, .notFound)
                        XCTAssertEqual(response.headers.contentType, .problemDetails)
                     })
    }
}
