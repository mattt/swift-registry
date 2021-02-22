@testable import Server
@testable import PackageRegistry
import XCTVapor

final class FetchReleaseManifestEndpointTests: EndpointTestCase {
    func testFetchManifestForAPackageRelease() throws {
        /*
         A client MAY send a `GET` request
         for a URI matching the expression `/{package}/{version}/Package.swift`
         to retrieve the package manifest for a release.
         A client SHOULD set the `Accept` header to
         `application/vnd.swift.registry.v1+swift`.

         ```http
         GET /@mona/LinkedList/1.1.1/Package.swift HTTP/1.1
         Host: packages.example.com
         Accept: application/vnd.swift.registry.v1+swift
         ```
         */
        try app.test(.GET, "@mona/LinkedList/1.1.1/Package.swift",
                     headers: ["Accept": "application/vnd.swift.registry.v1+swift"],
                     afterResponse: { response in
                        /*
                        A server SHALL set the `Content-Type` and `Content-Version` header fields
                        with the corresponding content type and API version number of the response.
                        */
                        XCTAssertEqual(response.headers.first(name: "Content-Version"), "1")

                        /*
                        If a release is found for the requested URI,
                        a server SHOULD respond with a status code of `200` (OK)
                        and the `Content-Type` header `text/x-swift`.
                        */
                        XCTAssertEqual(response.status, .ok)
                        XCTAssertEqual(response.headers.contentType, .swift)

                        /*
                        A server SHOULD respond with a `Content-Length` header
                        set to the size of the manifest in bytes.
                        */
                        XCTAssertEqual(Int(response.headers.first(name: .contentLength)!)!, response.body.readableBytes)

                        /*
                        A server SHOULD respond with a `Content-Disposition` header
                        set to `attachment` with a `filename` parameter equal to
                        the name of the manifest file
                        (for example, "Package.swift").
                        */
                        XCTAssertEqual(response.headers.contentDisposition?.value, .attachment)
                        XCTAssertEqual(response.headers.contentDisposition?.filename, "Package.swift")
                     })
    }

    func testFetchManifestForAnUnknownPackageRelease() throws {
        /*
         If no release is found for the requested URI,
         a server SHOULD respond with a status code of `404` (NOT FOUND).
         */
        try app.test(.GET, "@mona/LinkedList/0.0.0/Package.swift",
                     headers: ["Accept": "application/vnd.swift.registry.v1+swift"],
                     afterResponse: { response in
                        XCTAssertEqual(response.status, .notFound)
                        XCTAssertEqual(response.headers.contentType, .problemDetails)
                     })
    }

    func testFetchManifestForAPackageReleaseWithSwiftVersion() throws {
        /*
         A client MAY specify a `swift-version` query parameter
         to request a manifest for a particular version of Swift.

         ```http
         GET /@mona/LinkedList/1.1.1/Package.swift?swift-version=4.2 HTTP/1.1
         Host: packages.example.com
         Accept: application/vnd.swift.registry.v1+swift
         ```

         If the package includes a file named
         `Package@swift-{swift-version}.swift`,
         the server SHOULD respond with a status code of `200` (OK)
         and the content of that file in the response body.

         ```http
         HTTP/1.1 200 OK
         Cache-Control: public, immutable
         Content-Type: text/x-swift
         Content-Disposition: attachment; filename="Package@swift-4.2.swift"
         Content-Length: 361
         Content-Version: 1
         ETag: 24f6cd72352c4201df22a5be356d4d22

         // swift-tools-version:4.2
         import PackageDescription

         let package = Package(
             name: "LinkedList",
             products: [
                .library(name: "LinkedList", targets: ["LinkedList"])
             ],
             targets: [
                .target(name: "LinkedList"),
                .testTarget(name: "LinkedListTests", dependencies: ["LinkedList"]),
             ],
             swiftLanguageVersions: [.v3, .v4]
         )
         ```
         */
        try app.test(.GET, "@mona/LinkedList/1.1.1/Package.swift?swift-version=4.2",
                     headers: ["Accept": "application/vnd.swift.registry.v1+swift"],
                     afterResponse: { response in
                        /*
                        A server SHALL set the `Content-Type` and `Content-Version` header fields
                        with the corresponding content type and API version number of the response.
                        */
                        XCTAssertEqual(response.headers.first(name: "Content-Version"), "1")

                        /*
                        If a release is found for the requested URI,
                        a server SHOULD respond with a status code of `200` (OK)
                        and the `Content-Type` header `text/x-swift`.
                        */
                        XCTAssertEqual(response.status, .ok)
                        XCTAssertEqual(response.headers.contentType, .swift)

                        /*
                        A server SHOULD respond with a `Content-Length` header
                        set to the size of the manifest in bytes.
                        */
                        XCTAssertEqual(Int(response.headers.first(name: .contentLength)!)!, response.body.readableBytes)

                        /*
                        A server SHOULD respond with a `Content-Disposition` header
                        set to `attachment` with a `filename` parameter equal to
                        the name of the manifest file
                        (for example, "Package.swift").
                        */
                        XCTAssertEqual(response.headers.contentDisposition?.value, .attachment)
                        XCTAssertEqual(response.headers.contentDisposition?.filename, "Package@swift-4.2.swift")
                     })
    }

    func testFetchManifestForAPackageReleaseWithUnavailableSwiftVersion() throws {
        /*
         Otherwise,
         the server SHOULD respond with a status code of `303` (See Other)
         and redirect to the unqualified `Package.swift` resource.

         ```http
         HTTP/1.1 303 See Other
         Content-Version: 1
         Location: https://packages.example.com/@mona/LinkedList/1.1.1/Package.swift
         ```
         */
        try app.test(.GET, "@mona/LinkedList/1.1.1/Package.swift?swift-version=3.0",
                     headers: ["Accept": "application/vnd.swift.registry.v1+swift"],
                     afterResponse: { response in
                        XCTAssertEqual(response.status, .seeOther)

                        /*
                        A server SHALL set the `Content-Type` and `Content-Version` header fields
                        with the corresponding content type and API version number of the response.
                        */
                        XCTAssertEqual(response.headers.first(name: "Content-Version"), "1")
                     })
    }
}
