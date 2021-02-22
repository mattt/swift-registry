import XCTest
@testable import PackageRegistry

final class ReleaseTests: XCTestCase {
    func testTagNames() throws {
        XCTAssertEqual(Release(package: Package("@Alamofire/Alamofire")!, version: "5.0.0").tagName, "@alamofire/alamofire/5.0.0")
        XCTAssertEqual(Release(package: Package("@Flight-School/Money")!, version: "1.2.0").tagName, "@flight-school/money/1.2.0")
        XCTAssertEqual(Release(package: Package("@SwiftDocOrg/Git")!, version: "0.0.0+7b382046142480e3647d8198fc63c5e835117b92").tagName, "@swiftdocorg/git/0.0.0+7b382046142480e3647d8198fc63c5e835117b92")
    }

    func testArchivePaths() throws {
        XCTAssertEqual(Release(package: Package("@Alamofire/Alamofire")!, version: "5.0.0").archivePath, "al/am/@alamofire/alamofire/5.0.0.zip")
        XCTAssertEqual(Release(package: Package("@Flight-School/Money")!, version: "1.2.0").archivePath, "mo/ne/@flight-school/money/1.2.0.zip")
        XCTAssertEqual(Release(package: Package("@SwiftDocOrg/Git")!, version: "0.0.0+7b382046142480e3647d8198fc63c5e835117b92").archivePath, "3/@swiftdocorg/git/0.0.0+7b382046142480e3647d8198fc63c5e835117b92.zip")
    }
}
