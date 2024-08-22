import XCTest
@testable import Typesense

final class PresetTests: XCTestCase {
    override func setUp() async throws {
        try await createSingleCollectionSearchPreset()
    }
    override func tearDown() async throws  {
        try await tearDownPresets()
    }

    func testPresetRetrieve() async {
        do {
            let (result, _) = try await client.preset("test-id").retrieve()
            XCTAssertNotNil(result)
            guard let validResult = result else {
                throw DataError.dataNotFound
            }
            print(validResult)
            XCTAssertEqual("test-id", validResult.name)
            switch validResult.value {
            case .singleCollectionSearch(let value):
                XCTAssertEqual("apple", value.q)
            default:
                XCTAssertTrue(false)
            }
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testPresetDelete() async {
        do {
            let (result, _) = try await client.preset("test-id").delete()
            XCTAssertNotNil(result)
            guard let validResult = result else {
                throw DataError.dataNotFound
            }
            print(validResult)
            XCTAssertEqual("test-id", validResult.name)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }

    }

}
