import XCTest
@testable import Typesense

final class CollectionTests: XCTestCase {
    override func tearDown() async throws  {
       try! await tearDownCollections()
    }

    func testCollectionCreate() async {
        let schema = CollectionSchema(name: "companies", fields: [Field(name: "company_name", type: "string"), Field(name: "num_employees", type: "int32"), Field(name: "country", type: "string", facet: true)], defaultSortingField: "num_employees")
        do {
            let (collResp, _) = try await client.collections.create(schema: schema)
            XCTAssertNotNil(collResp)
            guard let validData = collResp else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "companies")
            XCTAssertNotNil(validData.fields)
            XCTAssertEqual(validData.fields.count, 3)
            XCTAssertEqual(validData.defaultSortingField, "num_employees")
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }

    func testCollectionDelete() async {
        do {
            try await createCollection()
            let (collResp, _) = try await client.collection(name: "companies").delete()
            XCTAssertNotNil(collResp)
            guard let validData = collResp else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "companies")
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testCollectionRetrieveAll() async {
        do {
            try await createCollection()
            let (collResp, _) = try await client.collections.retrieveAll()
            XCTAssertNotNil(collResp)
            guard let validData = collResp else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.count, 1)
            XCTAssertEqual(validData[0].name, "companies")
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testCollectionRetrieveOne() async {
        do {
            try await createCollection()
            let (collResp, _) = try await client.collection(name: "companies").retrieve()
            XCTAssertNotNil(collResp)
            guard let validData = collResp else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "companies")
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

}
