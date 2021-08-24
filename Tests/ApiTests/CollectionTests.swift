import XCTest
@testable import Typesense

final class CollectionTests: XCTestCase {
    func testCollections() {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        var myClient = Client(config: newConfig)
        
        //let mySchema = CollectionSchema(name: "Sample", fields: [Field(name: "Field1", type: Field.ModelType.int64, _optional: true, facet: false)], defaultSortingField: "Field1")
        let res = myClient.collections.retrieve()

    }
}
