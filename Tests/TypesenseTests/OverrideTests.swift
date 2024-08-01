import XCTest
@testable import Typesense

final class OverrideTests: XCTestCase {
    override func setUp() async throws {
        try? await setUpCollection()
        try! await createAnOverride()
    }

    override func tearDown() async throws  {
       try! await tearDownCollections()
    }

    func testOverrideRetrieve() async {
        do {
            let (result, _) = try await client.collection(name: "test-utils-collection").override("test-id").retrieve(metadataType: SearchOverrideExclude.self )
            guard let validOverride = result else {
                throw DataError.dataNotFound
            }
            print(validOverride)
            XCTAssertEqual("test-id", validOverride._id)
            XCTAssertEqual("exclude-id", validOverride.metadata?._id)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testOverrideDelete() async {
        do {
            let (result, _) = try await client.collection(name: "test-utils-collection").override("test-id").delete()
            guard let validOverride = result else {
                throw DataError.dataNotFound
            }
            print(validOverride)
            XCTAssertEqual("test-id", validOverride._id)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

}
