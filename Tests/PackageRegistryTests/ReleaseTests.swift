import XCTest
@testable import PackageRegistry

final class ReleaseTests: XCTestCase {
    func testTagNames() throws {
        XCTAssertEqual(Release(package: "github.com/Alamofire/Alamofire", version: "5.0.0").tagName, "github.com/alamofire/alamofire/5.0.0")
        XCTAssertEqual(Release(package: "github.com/Flight-School/Money", version: "1.2.0").tagName, "github.com/flight-school/money/1.2.0")
        XCTAssertEqual(Release(package: "github.com/SwiftDocOrg/Git", version: "0.0.0+7b382046142480e3647d8198fc63c5e835117b92").tagName, "github.com/swiftdocorg/git/0.0.0+7b382046142480e3647d8198fc63c5e835117b92")
    }

    func testArchivePaths() throws {
        XCTAssertEqual(Release(package: "github.com/Alamofire/Alamofire", version: "5.0.0").archivePath, "al/am/github.com/alamofire/alamofire/5.0.0.zip")
        XCTAssertEqual(Release(package: "github.com/Flight-School/Money", version: "1.2.0").archivePath, "mo/ne/github.com/flight-school/money/1.2.0.zip")
        XCTAssertEqual(Release(package: "github.com/SwiftDocOrg/Git", version: "0.0.0+7b382046142480e3647d8198fc63c5e835117b92").archivePath, "3/github.com/swiftdocorg/git/0.0.0+7b382046142480e3647d8198fc63c5e835117b92.zip")
    }
}
