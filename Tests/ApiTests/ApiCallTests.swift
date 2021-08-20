import XCTest
@testable import Typesense

final class ApiCallTests: XCTestCase {
    func testHealth() {
        var apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz"))
        var expectation:XCTestExpectation? = expectation(description: "Check health of system")
        
        apiCall.get(endPoint: "health") { result in
            let jsonRes = try! decoder.decode(HealthStatus.self, from: result!)
            XCTAssertTrue(jsonRes.ok)
            expectation?.fulfill()
            expectation = nil
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPostRequest() {
        var apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz"))
        var expectation:XCTestExpectation? = expectation(description: "Check POST request")
        
        let schema = CollectionSchema(name: "sample", fields: [Field(name: ".*", type: Field.ModelType.auto, fieldOptional: true, facet: false, index: true)])
        
        var schemaData: Data? = nil
        do {
            schemaData = try encoder.encode(schema)
            apiCall.post(endPoint: "collections", body: schemaData!) { result in
                expectation?.fulfill()
                expectation = nil
            }
        } catch {
            print("ERROR: Unable to resolve JSON from schema")
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
