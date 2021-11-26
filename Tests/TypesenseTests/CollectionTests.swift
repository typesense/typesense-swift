import XCTest
@testable import Typesense

final class CollectionTests: XCTestCase {
    func testCollectionCreate() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        
        let client = Client(config: config)
        
        let schema = CollectionSchema(name: "companies", fields: [Field(name: "name", type: "string", _optional: false, facet: false)], tokenSeparators: [], symbolsToIndex: [])
      
        XCTAssertNotNil(client.collections)
        XCTAssertEqual(client.collections.RESOURCEPATH, "collections")
        
    }
    
}
