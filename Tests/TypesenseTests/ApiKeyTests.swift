import XCTest
@testable import Typesense

final class ApiKeyTests: XCTestCase {
    override func tearDown() async throws  {
       try await tearDownAPIKeys()
    }

    func testKeyCreate() async {
        do {
            let adminKey = ApiKeySchema(_description: "Test key with all privileges", actions: ["*"], collections: ["*"])
            let (data, _) = try await client.keys().create(adminKey)
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData._description, "Test key with all privileges")
            XCTAssertEqual(validData.actions, ["*"])
            XCTAssertEqual(validData.collections, ["*"])
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }

    func testKeyRetrieve() async {
        do {
            let key = try await createAPIKey()
            let (data, _) = try await client.keys().retrieve(id: key._id)
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData._description, "Test key with all privileges")
            XCTAssertEqual(validData.actions, ["*"])
            XCTAssertEqual(validData.collections, ["*"])
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }

    func testKeyRetrieveAll() async {
        do {
            let key = try await createAPIKey()
            let (data, _) = try await client.keys().retrieve()
            XCTAssertNotNil(data)
            guard let validData = data?.keys else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData[0]._id, key._id)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }

    func testKeyDelete() async {
        do {
            let key = try await createAPIKey()
            let (data, _) = try await client.keys().delete(id: key._id)
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }
}
