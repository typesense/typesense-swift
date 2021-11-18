import XCTest
@testable import Typesense

final class ConfigurationTests: XCTestCase {
    func testQuickConfig() {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        let myClient = Client(config: newConfig)
        
        XCTAssertFalse(myClient.configuration.nodes.isEmpty)
    }
    
    func testQuickConfigConnectionTimeout() {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", connectionTimeoutSeconds: 8)
        let myClient = Client(config: newConfig)
        
        XCTAssertFalse(myClient.configuration.nodes.isEmpty)
        XCTAssertEqual(myClient.configuration.connectionTimeoutSeconds, 8)
    }
    
    func testQuickConfigNearestNode() {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", nearestNode: Node(host: "localhost", port: "8108", nodeProtocol: "http"))
        let myClient = Client(config: newConfig)
        
        XCTAssertFalse(myClient.configuration.nodes.isEmpty)
        XCTAssertNotNil(myClient.configuration.nearestNode)
    }
}
