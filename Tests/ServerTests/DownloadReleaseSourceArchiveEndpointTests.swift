@testable import Server
@testable import PackageRegistry
import XCTVapor

final class DownloadReleaseSourceArchiveEndpointTests: EndpointTestCase {
    func testDownloadSourceArchiveForRelease() throws {
        /*
         A client MAY send a `GET` request
         for a URI matching the expression `/{package}/{version}`
         to retrieve a release's source archive.
         A client SHOULD set the `Accept` header to
         `application/vnd.swift.registry.v1+zip`
         and SHOULD append the `.zip` extension to the requested URI.

         ```http
         GET /github.com/mona/LinkedList/1.1.1.zip HTTP/1.1
         Host: packages.example.com
         Accept: application/vnd.swift.registry.v1
         ```
         */
        try app.test(.GET, "github.com/mona/LinkedList/1.1.1.zip",
                     headers: ["Accept": "\(Registry.v1 + "zip")"],
                     afterResponse: { response in
                        /*
                        A server SHALL set the `Content-Type` and `Content-Version` header fields
                        with the corresponding content type and API version number of the response.
                        */
                        XCTAssertEqual(response.headers.first(name: "Content-Version"), "1")

                        /*
                        If a release is found for the requested URI,
                        a server SHOULD respond with a status code of `200` (OK)
                        and the `Content-Type` header `application/zip`.
                        */
                        XCTAssertEqual(response.status, .ok)
                        XCTAssertEqual(response.headers.contentType, .zip)

                        /*
                        A server SHALL respond with a `Content-Length` header
                        set to the size of the archive in bytes.
                        */
                        XCTAssertEqual(Int(response.headers.first(name: .contentLength)!)!, response.body.readableBytes)

                        /*
                        A server SHALL respond with a `Digest` header
                        containing a SHA-256 checksum for the source archive.
                        */
                        XCTAssertEqual(response.headers.first(name: .digest)?.hasPrefix("sha-256="), true)

                        /*
                        A server SHOULD respond with a `Content-Disposition` header
                        set to `attachment` with a `filename` parameter equal to the name of the package
                        followed by a hyphen (`-`), the version number, and file extension
                        (for example, "LinkedList-1.1.1.zip").
                        */
                        XCTAssertEqual(response.headers.contentDisposition?.value, .attachment)
                        XCTAssertEqual(response.headers.contentDisposition?.filename, "LinkedList-1.1.1.zip")
                     })
    }
}
