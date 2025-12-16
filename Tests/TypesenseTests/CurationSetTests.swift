import XCTest
@testable import Typesense

final class CurationSetTests: XCTestCase {
    override func setUp() async throws {
        try await createCurationSet()
    }

    override func tearDown() async throws  {
        try await tearDownCurationSets()
    }

    func testCurationSetRetrieve() async {
        do {
            let (result, _) = try await client.curationSet("curate_products").retrieve()
            guard let validData = result else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual("curate_products", validData.name)
            XCTAssertEqual(2, validData.items[0].includes?.count)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testCurationSetDelete() async {
        do {
            let (result, _) = try await client.curationSet("curate_products").delete()
            guard let validData = result else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual("curate_products", validData.name)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }

        do{
            let _ = try await client.curationSet("curate_products").retrieve()
        } catch HTTPError.clientError(let code, _){
            if code != 404 {
                XCTAssertTrue(false, "Curation set should have been deleted")
            }
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testCurationSetItemsRetrieve() async {
        do {
            let (result, _) = try await client.curationSet("curate_products").items().retrieve()
            guard let validData: [CurationItemSchema] = result else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual("customize-apple", validData[0].id)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testCurationSetItemsUpsert() async {
        do {
            let (result, _) = try await client.curationSet("curate_products").items().upsert("customize-apple-2",  CurationItemCreateSchema(
                rule: CurationRule( query: "apple", match: .exact),
                includes: [
                    CurationInclude(id: "422", position: 1),
                    CurationInclude(id: "54", position: 2),
                ], excludes: [CurationExclude(id: "287")],
            ))
            guard let validData = result else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual("customize-apple-2", validData.id)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testCurationSetItemRetrieve() async {
        do {
            let (result, _) = try await client.curationSet("curate_products").item("customize-apple").retrieve()
            guard let validData = result else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual("customize-apple", validData.id)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testCurationSetItemDelete() async {
        do {
            let (result, _) = try await client.curationSet("curate_products").item("customize-apple").delete()
            guard let validData = result else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual("customize-apple", validData.id)

            let (curationSet, _) = try await client.curationSet("curate_products").retrieve()
            guard let validCurationSet = curationSet else {
                throw DataError.dataNotFound
            }
            XCTAssertEqual(0, validCurationSet.items.count)
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
