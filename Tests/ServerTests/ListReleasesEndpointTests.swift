@testable import Server
@testable import PackageRegistry
import XCTVapor

final class ListReleasesEndpointTests: EndpointTestCase {
    func testListReleasesForPackage() throws {
        /*
         A client MAY send a `GET` request
         for a URI matching the expression `/{package}`
         to retrieve a list of the available releases for a particular package.
         A client SHOULD set the `Accept` header with
         the `application/vnd.swift.registry.v1+json` content type
         and MAY append the `.json` extension to the requested URI.

         ```http
         GET /@mona/LinkedList HTTP/1.1
         Host: packages.example.com
         Accept: application/vnd.swift.registry.v1+json
         ```

         A server SHOULD respond with a JSON document
         containing all of the releases for the requested package.

         ```http
         HTTP/1.1 200 OK
         Content-Type: application/json
         Content-Version: 1
         Link: <https://@mona/LinkedList>; rel="canonical",
               <https://packages.example.com/@mona/LinkedList/1.1.1>; rel="latest-version",
               <https://github.com/sponsors/mona>; rel="payment"

         {
            "releases": {
                "1.1.1": {
                    "url": "https://packages.example.com/@mona/LinkedList/1.1.1"
                },
                "1.1.0": {
                    "url": "https://packages.example.com/@mona/LinkedList/1.1.0",
                    "problem": {
                        "status": 410,
                        "title": "Gone",
                        "detail": "this release was removed from the registry"
                    }
                },
                "1.0.0": {
                    "url": "https://packages.example.com/@mona/LinkedList/1.0.0"
                }
            }
         }
         ```
         */
        try app.test(.GET, "@mona/LinkedList",
                     headers: ["Accept": "application/vnd.swift.registry.v1+json"],
                     afterResponse: { response in
                        /*
                        A server SHALL set the `Content-Type` and `Content-Version` header fields
                        with the corresponding content type and API version number of the response.
                        */
                        XCTAssertEqual(response.headers.first(name: "Content-Version"), "1")

                        /*
                        If a package is found for the requested URI,
                        a server SHOULD respond with a status code of `200` (OK)
                        and the `Content-Type` header `application/json`.
                        */
                        XCTAssertEqual(response.status, .ok)
                        XCTAssertEqual(response.headers.contentType, .json)

                        /*
                        The response body SHALL contain a JSON object
                        nested at a top-level `releases` key,
                        whose keys are version numbers for releases
                        and values are objects containing the following fields:

                        | Key       | Type   | Description                           | Requirement Level |
                        | --------- | ------ | ------------------------------------- | ----------------- |
                        | `url`     | String | A URI for the release                 | REQUIRED          |
                        | `problem` | Object | A [problem details][RFC 7807] object. | OPTIONAL          |
                        */
                        let payload = try response.body.getJSONDecodable([String: [String: [String: String]]].self, decoder: JSONDecoder(), at: 0, length: response.body.readableBytes)
                        XCTAssertNotNil(payload)
                        XCTAssertNotNil(payload?["releases"])
                        XCTAssertNotNil(payload?["releases"]?["1.1.1"])
                        XCTAssertEqual(payload?["releases"]?["1.1.1"]?["url"]?.hasSuffix("@mona/linkedlist/1.1.1"), true)
                     })
    }

    func testListReleasesForUnknownPackage() throws {
        /*
        If no package is found for the requested URI,
        a server SHOULD respond with a status code of `404` (NOT FOUND).
        */
        try app.test(.GET, "@mona/UnlinkedList",
                     headers: ["Accept": "application/vnd.swift.registry.v1+json"],
                     afterResponse: { response in
                        XCTAssertEqual(response.status, .notFound)
                        XCTAssertEqual(response.headers.contentType, .problemDetails)
                     })
    }
}
