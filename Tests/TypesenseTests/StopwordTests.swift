import XCTest
@testable import Typesense

final class StopwordTests: XCTestCase {
    override func tearDown() async throws  {
       try! await tearDownStopwords()
    }

    func testStopwordRetrieve() async {
        try! await createStopwordSet()
        do {
            let (result, _) = try await client.stopword("test-id-stopword-set").retrieve()
            XCTAssertNotNil(result)
            guard let validResult = result else {
                throw DataError.dataNotFound
            }
            print(validResult)
            XCTAssertEqual("test-id-stopword-set", validResult._id)
            XCTAssertEqual(["states","united"], validResult.stopwords)
            XCTAssertEqual("en", validResult.locale)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testStopwordDelete() async {
        try! await createStopwordSet()
        do {
            let (result, _) = try await client.stopword("test-id-stopword-set").delete()
            guard let validResult = result else {
                throw DataError.dataNotFound
            }
            print(validResult)
            XCTAssertEqual("test-id-stopword-set", validResult._id)
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

}
