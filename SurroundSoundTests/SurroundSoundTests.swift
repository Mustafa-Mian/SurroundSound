#if canImport(Testing)
import Testing
@testable import SurroundSound

@Suite("Basic smoke tests")
struct SurroundSoundTests {
    @Test func example() throws {
        #expect(true)
    }
}
#else
import XCTest
@testable import SurroundSound

final class SurroundSoundTests: XCTestCase {
    func testExample() throws {
        XCTAssertTrue(true)
    }
}
#endif
