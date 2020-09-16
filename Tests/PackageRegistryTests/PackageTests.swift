import XCTest
@testable import PackageRegistry

final class PackageTests: XCTestCase {
    func testDirectoryPaths() throws {
        XCTAssertEqual(Package("github.com/Alamofire/Alamofire").directoryPath, "al/am/github.com/alamofire/alamofire")
        XCTAssertEqual(Package("github.com/Flight-School/Money").directoryPath, "mo/ne/github.com/flight-school/money")
        XCTAssertEqual(Package("github.com/SwiftDocOrg/Git").directoryPath, "3/github.com/swiftdocorg/git")
    }

    func testPackageManifestFileValidation() throws {
        let test = Package.isValidManifestFile

        XCTAssertTrue(test("Package.swift"))
        XCTAssertTrue(test("Package@swift-3.swift"))
        XCTAssertTrue(test("Package@swift-4.swift"))
        XCTAssertTrue(test("Package@swift-4.2.swift"))
        XCTAssertTrue(test("Package@swift-4.2.1.swift"))

        XCTAssertFalse(test("README.md"))
        XCTAssertFalse(test("Package"))
        XCTAssertFalse(test(".swift"))
        XCTAssertFalse(test("package.swift"))
        XCTAssertFalse(test("Package@.swift"))
        XCTAssertFalse(test("Package@swift.swift"))
        XCTAssertFalse(test("Package@swift-1.2.3.4.swift"))
    }
}
