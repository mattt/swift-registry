@testable import Server
@testable import PackageRegistry
import XCTVapor

final class PublishReleaseEndpointTests: EndpointTestCase {
    func testPublishANewPackageRelease() throws {
        /*
         A client MAY send a `PUT` request
         for a URI matching the expression
         `/{package}/{version}{?commit,branch,tag,path,url}`
         to publish a release of a package.

         ```http
         PUT /github.com/mona/LinkedList/1.1.1 HTTP/1.1
         Host: packages.example.com
         Accept: application/vnd.swift.registry.v1
         ```
         */
        try app.test(.PUT, "github.com/mona/LinkedList/2.0.0",
                     headers: ["Accept": "application/vnd.swift.registry.v1+zip"],
                     afterResponse: { response in
                        /*
                        A server SHALL set the `Content-Type` and `Content-Version` header fields
                        with the corresponding content type and API version number of the response.
                        */
                        XCTAssertEqual(response.headers.first(name: "Content-Version"), "1")

                        /*
                        If processing is done synchronously,
                        the server SHALL respond with a status code of `201` (Created)
                        to indicate that the package release was published.
                        */
                        XCTAssertEqual(response.status, .created)
                     })
    }
}
