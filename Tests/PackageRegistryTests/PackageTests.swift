import XCTest
@testable import PackageRegistry

final class PackageTests: XCTestCase {
    func testDirectoryPaths() throws {
        XCTAssertEqual(Package("@Alamofire/Alamofire")?.directoryPath, "al/am/@alamofire/alamofire")
        XCTAssertEqual(Package("@Flight-School/Money")?.directoryPath, "mo/ne/@flight-school/money")
        XCTAssertEqual(Package("@SwiftDocOrg/Git")?.directoryPath, "3/@swiftdocorg/git")
    }

    func testIdentifierInitialization() {
        let package = Package("@mona/LinkedList")
        XCTAssertNotNil(package)
        XCTAssertEqual(package?.scope, "@mona")
        XCTAssertEqual(package?.name, "LinkedList")
    }

    func testCaseInsensitivity() {
        XCTAssertEqual(
            Package("@mona/linkedlist"),
            Package("@MONA/LINKEDLIST")
        )
    }

    func testDiacriticInsensitivity() {
        XCTAssertEqual(
            Package("@mona/LinkedList"),
            Package("@mona/LïnkédLîst")
        )
    }

    func testNormalizationInsensitivity() {
        // Combining sequences
        XCTAssertEqual(
            Package("@mona/E\u{0301}clair"), // ◌́ COMBINING ACUTE ACCENT (U+0301)
            Package("@mona/\u{00C9}clair") // É LATIN CAPITAL LETTER E WITH ACUTE (U+00C9)
        )

        // Ordering of combining marks
        XCTAssertEqual(
            // ◌̇ COMBINING DOT ABOVE (U+0307)
            // ◌̣ COMBINING DOT BELOW (U+0323)
            Package("@mona/q\u{0307}\u{0323}"),
            Package("@mona/q\u{0323}\u{0307}")
        )

        // Hangul & conjoining jamo
        XCTAssertEqual(
            Package("@mona/\u{AC00}"), // 가 HANGUL SYLLABLE GA (U+AC00)
            Package("@mona/\u{1100}\u{1161}") // ᄀ HANGUL CHOSEONG KIYEOK (U+1100) + ᅡ HANGUL JUNGSEONG A (U+1161)
        )

        // Singleton equivalence
        XCTAssertEqual(
            Package("@mona/\u{03A9}"), // Ω GREEK CAPITAL LETTER OMEGA (U+03A9)
            Package("@mona/\u{1D6C0}") // 𝛀 MATHEMATICAL BOLD CAPITAL OMEGA (U+1D6C0)
        )

        // Font variants
        XCTAssertEqual(
            Package("@mona/ℌello"), // ℌ BLACK-LETTER CAPITAL H (U+210C)
            Package("@mona/hello")
        )

        // Circled variants
        XCTAssertEqual(
            Package("@mona/①"), // ① CIRCLED DIGIT ONE (U+2460)
            Package("@mona/1")
        )

        // Width variants
        XCTAssertEqual(
            Package("@mona/ＬｉｎｋｅｄＬｉｓｔ"), // Ｌ FULLWPackageTH LATIN CAPITAL LETTER L (U+FF2C)
            Package("@mona/LinkedList")
        )

        XCTAssertEqual(
            Package("@mona/ｼｰｻｲﾄﾞﾗｲﾅｰ"), // ｼ HALFWPackageTH KATAKANA LETTER SI (U+FF7C)
            Package("@mona/シーサイドライナー")
        )

        // Ligatures
        XCTAssertEqual(
            Package("@mona/ǅungla"), // ǅ LATIN CAPITAL LETTER D WITH SMALL LETTER Z WITH CARON (U+01C5)
            Package("@mona/dzungla")
        )
    }

    func testValidIdentifiers() {
        XCTAssertNotNil(Package("@1/A"))
        XCTAssertNotNil(Package("@mona/LinkedList"))
        XCTAssertNotNil(Package("@m-o-n-a/LinkedList"))
        XCTAssertNotNil(Package("@mona/Linked_List"))
        XCTAssertNotNil(Package("@mona/قائمةمرتبطة"))
        XCTAssertNotNil(Package("@mona/链表"))
        XCTAssertNotNil(Package("@mona/רשימה_מקושרת"))
        XCTAssertNotNil(Package("@mona/รายการที่เชื่อมโยง"))
    }

    func testInvalidIdentifiers() {
        // Invalid identifiers
        XCTAssertNil(Package.init("")) // empty
        XCTAssertNil(Package("/")) // empty namespace and name
        XCTAssertNil(Package("@/")) // empty namespace and name with leading @
        XCTAssertNil(Package("@mona")) // namespace only
        XCTAssertNil(Package("LinkedList")) // name only

        // Invalid namespaces
        XCTAssertNil(Package("mona/LinkedList")) // missing @
        XCTAssertNil(Package("@/LinkedList")) // empty namespace
        XCTAssertNil(Package("@-mona/LinkedList")) // leading hyphen
        XCTAssertNil(Package("@mona-/LinkedList")) // trailing hyphen
        XCTAssertNil(Package("@mo--na/LinkedList")) // consecutive hyphens

        // Invalid names
        XCTAssertNil(Package("@mona/")) // empty name
        XCTAssertNil(Package("@mona/_LinkedList")) // underscore in start
        XCTAssertNil(Package("@mona/🔗List")) // emoji
        XCTAssertNil(Package("@mona/Linked-List")) // hyphen
        XCTAssertNil(Package("@mona/LinkedList.swift")) // dot
        XCTAssertNil(Package("@mona/i⁹")) // superscript numeral
        XCTAssertNil(Package("@mona/i₉")) // subscript numeral
        XCTAssertNil(Package("@mona/㌀")) // squared characters
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
