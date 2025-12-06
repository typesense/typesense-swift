import XCTest
@testable import Typesense

final class CurationSetsTests: XCTestCase {
    override func tearDown() async throws  {
        try await tearDownCurationSets()
    }

    func testCurationSetsUpsert() async {
        let schema = CurationSetCreateSchema(items: [
                CurationItemCreateSchema(
                    rule: CurationRule( match: .exact, query: "apple"),
                    excludes: [CurationExclude(id: "287")],
                    id: "customize-apple",
                    includes: [
                        CurationInclude(id: "422", position: 1),
                        CurationInclude(id: "54", position: 2),
                    ]
                )
            ])
        do {
            let (result, _) = try await client.curationSets().upsert("curate_products_test", schema)
            XCTAssertNotNil(result)
            guard let validData = result else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual("curate_products_test", validData.name)
            XCTAssertEqual("apple", validData.items[0].rule.query)
            XCTAssertEqual("422", validData.items[0].includes?[0].id)
            XCTAssertEqual("287", validData.items[0].excludes?[0].id)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testCurationSetsRetrieve() async {
        do {
            try await createCurationSet()
            let (data, _) = try await client.curationSets().retrieve()
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(1, validData.count)
            XCTAssertEqual("curate_products", validData[0].name)
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
