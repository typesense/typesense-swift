import XCTest
@testable import Typesense

final class CollectionTests: XCTestCase {
    func testCollectionCreate() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        
        var client = Client(config: config)
        
        let schema = CollectionSchema(name: "companies", fields: [Field(name: "company_name", type: "string"), Field(name: "num_employees", type: "int32"), Field(name: "country", type: "string", facet: true)], defaultSortingField: "num_employees",  tokenSeparators: [], symbolsToIndex: [])
        
        do {
            let (data, _) = try await client.collections.create(schema: schema)
            guard let validData = data else {
                throw DataError.unableToParse
            }
            let collResp = try decoder.decode(CollectionResponse.self, from: validData)
            print(collResp)
        } catch HTTPError.serverError(let error) {
            print(error.desc)
            print("The response status code is \(error.code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    func testCollectionDelete() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        
        var client = Client(config: config)
        
        do {
            let (data, _) = try await client.collections.delete(name: "companies")
            guard let validData = data else {
                throw DataError.unableToParse
            }
            let collResp = try decoder.decode(CollectionResponse.self, from: validData)
            print(collResp)
        } catch HTTPError.serverError(let (code, desc)) {
            print(desc)
            print("The response status code is \(code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
}
