import XCTest
@testable import Typesense

final class ApiKeyTests: XCTestCase {
    func testKeyCreate() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)
        
        do {
            let adminKey = ApiKeySchema(_description: "Test key with all privileges", actions: ["*"], collections: ["*"])
            
            let (data, _) = try await myClient.keys().create(adminKey)
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData._description, "Test key with all privileges")
            XCTAssertEqual(validData.actions, ["*"])
            XCTAssertEqual(validData.collections, ["*"])
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }
    
    func testKeyRetrieve() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)
        
        do {
            let (data, _) = try await myClient.keys().retrieve(id: 1)
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData._description, "Test key with all privileges")
            XCTAssertEqual(validData.actions, ["*"])
            XCTAssertEqual(validData.collections, ["*"])
        } catch ResponseError.apiKeyNotFound(let desc) {
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
    
    func testKeyRetrieveAll() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)
        
        do {
            let (data, _) = try await myClient.keys().retrieve()
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }
    
    func testKeyDelete() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)
        
        do {
            let (data, _) = try await myClient.keys().delete(id: 0)
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
        } catch ResponseError.apiKeyNotFound(let desc) {
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
}
