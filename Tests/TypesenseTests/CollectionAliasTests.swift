import XCTest
@testable import Typesense

final class CollectionAliasTests: XCTestCase {
    override func tearDown() async throws  {
       try! await tearDownAliases()
    }

    func testAliasUpsert() async {
        do {
            let aliasCollection = CollectionAliasSchema(collectionName: "companies_june")
            let (data, _) = try await client.aliases().upsert(name: "companies", collection: aliasCollection)
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "companies")
            XCTAssertEqual(validData.collectionName, "companies_june")
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testAliasRetrieve() async {
        do {
            try await createAlias()
            let (data, _) = try await client.aliases().retrieve(name: "companies")
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "companies")
            XCTAssertEqual(validData.collectionName, "companies_june")
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testAliasRetrieveAll() async {
        do {
            try await createAlias()
            let (data, _) = try await client.aliases().retrieve()
            XCTAssertNotNil(data)
            guard let validData = data?.aliases else {
                throw DataError.dataNotFound
            }
            XCTAssertEqual(validData.count, 1)
            XCTAssertEqual(validData[0].collectionName, "companies_june")
            XCTAssertEqual(validData[0].name, "companies")
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testAliasDelete() async {
        do {
            try await createAlias()
            let (data, _) = try await client.aliases().delete(name: "companies")
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "companies")
            XCTAssertEqual(validData.collectionName, "companies_june")
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
}
