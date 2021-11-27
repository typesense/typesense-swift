import XCTest
@testable import Typesense

final class CollectionTests: XCTestCase {
    func testCollectionCreate() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        
        var client = Client(config: config)
        
        let schema = CollectionSchema(name: "companies", fields: [Field(name: "company_name", type: "string"), Field(name: "num_employees", type: "int32"), Field(name: "country", type: "string", facet: true)], defaultSortingField: "num_employees")
        
        do {
            let (collResp, _) = try await client.collections.create(schema: schema)
            guard let validData = collResp else {
                throw DataError.unableToParse
            }
            print(validData)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    func testCollectionDelete() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        
        var client = Client(config: config)
        
        do {
            let (collResp, _) = try await client.collections.delete(name: "companies")
            guard let validData = collResp else {
                throw DataError.unableToParse
            }
            print(validData)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    func testCollectionRetrieveAll() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        
        var client = Client(config: config)
        
        do {
            let (collResp, _) = try await client.collections.retrieveAll()
            guard let validData = collResp else {
                throw DataError.unableToParse
            }
            print(validData)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    func testCollectionRetrieveOne() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        
        var client = Client(config: config)
        
        do {
            let (collResp, _) = try await client.collections.retrieve(name: "companies")
            guard let validData = collResp else {
                throw DataError.unableToParse
            }
            print(validData)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
}
