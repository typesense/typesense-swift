import XCTest
@testable import Typesense

final class PresetsTests: XCTestCase {
    override func tearDown() async throws  {
       try await tearDownPresets()
    }

    func testPresetsUpsertSearchParameters() async {
        let schema = PresetUpsertSchema(
            value: PresetValue.singleCollectionSearch(SearchParameters(q: "apple"))
        )
        do {
            let (result, _) = try await client.presets().upsert(presetName: "test-id", params: schema)
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

    func testPresetsUpsertMultiSearchSearchesParameter() async {
        let schema = PresetUpsertSchema(
            value: PresetValue.multiSearch(MultiSearchSearchesParameter(searches: [MultiSearchCollectionParameters(q: "apple")]))
        )
        do {
            let (result, _) = try await client.presets().upsert(presetName: "test-id", params: schema)
            XCTAssertNotNil(result)
            guard let validResult = result else {
                throw DataError.dataNotFound
            }
            print(validResult)
            XCTAssertEqual("test-id", validResult.name)
            switch validResult.value {
            case .multiSearch(let value):
                XCTAssertEqual("apple", value.searches[0].q)
            default:
                XCTAssertTrue(false)
            }
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testPresetsRetrieveAll() async {
        do {
            try await createSingleCollectionSearchPreset();
            try await createMultiSearchPreset();
            let (result, _) = try await client.presets().retrieve()
            guard let validResult = result else {
                throw DataError.dataNotFound
            }
            print(validResult)
            XCTAssertEqual(2, validResult.presets.count)
            for preset in validResult.presets{
                switch preset.value {
                case .singleCollectionSearch(let value):
                    XCTAssertEqual("test-id", preset.name)
                    XCTAssertEqual("apple", value.q)
                case .multiSearch(let value):
                    XCTAssertEqual("test-id-preset-multi-search", preset.name)
                    XCTAssertEqual("banana", value.searches[0].q)
                }
            }
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

}
