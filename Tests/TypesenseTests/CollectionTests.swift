import XCTest
@testable import Typesense

final class CollectionTests: XCTestCase {
    func testCollectionCreate() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        
        let client = Client(config: config)
        
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
        } catch ResponseError.collectionAlreadyExists(let desc) {
            print(desc)
            XCTAssertTrue(true)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }
    
    func testCollectionDelete() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        
        let client = Client(config: config)
        
        do {
            let (collResp, _) = try await client.collection(name: "companies").delete()
            XCTAssertNotNil(collResp)
            guard let validData = collResp else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "companies")
        } catch ResponseError.collectionDoesNotExist(let desc) {
            print(desc)
            XCTAssertTrue(true)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
    func testCollectionRetrieveAll() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        
        let client = Client(config: config)
        
        do {
            let (collResp, _) = try await client.collections.retrieveAll()
            XCTAssertNotNil(collResp)
            guard let validData = collResp else {
                throw DataError.dataNotFound
            }
            print(validData)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
    func testCollectionRetrieveOne() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        
        let client = Client(config: config)
        
        do {
            let (collResp, _) = try await client.collection(name: "companies").retrieve()
            XCTAssertNotNil(collResp)
            guard let validData = collResp else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "companies")
        } catch ResponseError.collectionDoesNotExist(let desc) {
            print(desc)
            XCTAssertTrue(true)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
}
