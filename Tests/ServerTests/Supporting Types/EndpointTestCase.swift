@testable import Server
@testable import PackageRegistry
import XCTVapor
import ZIPFoundation

open class EndpointTestCase: XCTestCase {
    let app = Application(.testing)
    var registry: Registry!

    open override func setUpWithError() throws {
        let url = try temporaryDirectory()

        let configuration: [String: String] = [
            "user.name": "Swift Package Registry",
            "user.email": "noreply@swift.org"
        ]
        let registry = try Registry.create(at: url, with: configuration)

        registry.archiver = { release in
            let archive = Archive(accessMode: .create)!

            try archive.addEntry(with: "README.md", content: "# LinkedList")

            try archive.addEntry(with: "Package.swift", content:
                #"""
                // swift-tools-version:5.0
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
                    swiftLanguageVersions: [.v4, .v5]
                )
                """#
            )

            try archive.addEntry(with: "Package@swift-4.2.swift", content:
                #"""
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
                """#
            )

            return archive.data!
        }

        try registry.publish(version: "1.0.0", of: "github.com/mona/LinkedList")
        try registry.publish(version: "1.1.0", of: "github.com/mona/LinkedList")
        try registry.publish(version: "1.1.1", of: "github.com/mona/LinkedList")

        try configure(app, with: registry)

        try super.setUpWithError()
    }

    open override func tearDownWithError() throws {
        app.shutdown()

        try super.tearDownWithError()
    }
}

// MARK: -

fileprivate extension Archive {
    func addEntry(with path: String, content: String) throws {
        let data = content.data(using: .utf8)!
        try addEntry(with: path, type: .file, uncompressedSize: numericCast(data.count), provider: { (position, size) -> Data in
            return data.subdata(in: position..<position+size)
        })
    }
}
