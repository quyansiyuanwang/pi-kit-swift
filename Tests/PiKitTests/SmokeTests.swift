import Testing
@testable import PiKit

@Suite("PiKit smoke")
struct SmokeTests {
    @Test func version() {
        #expect(PiKit.version == "0.1.0")
    }
}
