import XCTest
@testable import Typesense

final class StopwordsTests: XCTestCase {
    override func tearDown() async throws  {
       try! await tearDownStopwords()
    }

    func testStopwordsUpsert() async {
        let schema = StopwordsSetUpsertSchema(
            stopwords: ["states","united"],
            locale: "en"
        )
        do {
            let (result, _) = try await client.stopwords().upsert(stopwordsSetId: "test-id", params: schema)
            XCTAssertNotNil(result)
            guard let validResult = result else {
                throw DataError.dataNotFound
            }
            print(validResult)
            XCTAssertEqual("test-id", validResult._id)
            XCTAssertEqual(["states","united"], validResult.stopwords)
            XCTAssertEqual("en", validResult.locale)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testStopwordsRetrieveAll() async {
        try! await createStopwordSet()
        do {
            let (result, _) = try await client.stopwords().retrieve()
            guard let validResult = result else {
                throw DataError.dataNotFound
            }
            print(validResult)
            XCTAssertEqual(1, validResult.count)
            XCTAssertEqual("test-id-stopword-set", validResult[0]._id)
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

}
