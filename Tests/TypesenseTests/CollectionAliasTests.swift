import XCTest
@testable import Typesense

final class CollectionAliasTests: XCTestCase {
    func testAliasUpsert() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)

        do {

            let aliasCollection = CollectionAliasSchema(collectionName: "companies_june")
            let (data, _) = try await myClient.aliases().upsert(name: "companies", collection: aliasCollection)
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "companies")
            XCTAssertEqual(validData.collectionName, "companies_june")
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testAliasRetrieve() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)

        do {
            let (data, _) = try await myClient.aliases().retrieve(name: "companies")
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "companies")
            XCTAssertEqual(validData.collectionName, "companies_june")
        } catch ResponseError.aliasNotFound(let desc) {
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

    func testAliasRetrieveAll() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)

        do {
            let (data, _) = try await myClient.aliases().retrieve()
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            if(validData.aliases.count > 0) {
                XCTAssertEqual(validData.aliases[0].collectionName, "companies_june")
                XCTAssertEqual(validData.aliases[0].name, "companies")
            }
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
    func testAliasDelete() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)

        do {
            let (data, _) = try await myClient.aliases().delete(name: "companies")
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "companies")
            XCTAssertEqual(validData.collectionName, "companies_june")
        } catch ResponseError.aliasNotFound(let desc) {
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
