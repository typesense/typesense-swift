import XCTest
@testable import Typesense

final class CollectionTests: XCTestCase {
    func testCreateCollection() {
        var expectation:XCTestExpectation? = expectation(description: "Check Creation of Collection")
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        var myClient = Client(config: newConfig)
        
        let schema = CollectionSchema(name: "sample1", fields: [Field(name: ".*", type: Field.ModelType.auto, fieldOptional: true, facet: false, index: true)])
    
        myClient.collections.create(schema: schema) { result, response, error in
            expectation?.fulfill()
            expectation = nil
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRetrieveAllCollections() {
        var expectation:XCTestExpectation? = expectation(description: "Check retrieval of all Collections")
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        var myClient = Client(config: newConfig)
            
        myClient.collections.retrieveAll { result, response, error in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            if let res = response as? HTTPURLResponse {
                //Succesfull fetch of all Collections
                if(res.statusCode == 200) {
                    XCTAssertEqual(res.statusCode, 200)
                    expectation?.fulfill()
                    expectation = nil
                }
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDeleteCollection() {
        var expectation:XCTestExpectation? = expectation(description: "Check Deletion of Collection")
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        var myClient = Client(config: newConfig)
        
        let schema = CollectionSchema(name: "deleteSample", fields: [Field(name: ".*", type: Field.ModelType.auto, fieldOptional: true, facet: false, index: true)])
    
        myClient.collections.create(schema: schema) { result, response, error in
                XCTAssertNil(error)
            myClient.collections.delete(name: "deleteSample") { delResult, delResponse, delError in
                XCTAssertNil(delError)
                if let res = delResponse as? HTTPURLResponse {
                    //Succesfull delete of Collection
                    if(res.statusCode == 200) {
                        XCTAssertEqual(res.statusCode, 200)
                        expectation?.fulfill()
                        expectation = nil
                    }
                }
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
