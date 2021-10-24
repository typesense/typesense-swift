import XCTest

@testable import Typesense

final class ApiCallTests: XCTestCase {
    
    func testDefaultConfiguration() {
        let apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz"))
        
        XCTAssertNotNil(apiCall)
        XCTAssertNotNil(apiCall.nodes)
        XCTAssertEqual(apiCall.apiKey, "xyz")
        XCTAssertNil(apiCall.nearestNode)
        XCTAssertEqual(apiCall.connectionTimeoutSeconds, 10)
        XCTAssertEqual(apiCall.healthcheckIntervalSeconds, 15)
        XCTAssertEqual(apiCall.numRetries, 3)
        XCTAssertEqual(apiCall.retryIntervalSeconds, 0.1)
        XCTAssertEqual(apiCall.sendApiKeyAsQueryParam, false)
    }
    
    func testCustomConfiguration() {
        let apiCall = ApiCall(config: Configuration(
            nodes:
                [Node(host: "localhost", port: "8108", nodeProtocol: "http"),
                 Node(host: "localhost", port: "8109", nodeProtocol: "http")
                ],
            apiKey: "abc",
            connectionTimeoutSeconds: 100,
            nearestNode: Node(host: "localhost", port: "8000", nodeProtocol: "http"),
            healthcheckIntervalSeconds: 150,
            numRetries: 6,
            retryIntervalSeconds: 0.2,
            sendApiKeyAsQueryParam: true)
        )
        
        XCTAssertNotNil(apiCall)
        XCTAssertNotNil(apiCall.nodes)
        XCTAssertNotNil(apiCall.nearestNode)
        XCTAssertEqual(apiCall.nodes.count, 2)
        XCTAssertEqual(apiCall.apiKey, "abc")
        XCTAssertNotNil(apiCall.nearestNode)
        XCTAssertEqual(apiCall.connectionTimeoutSeconds, 100)
        XCTAssertEqual(apiCall.healthcheckIntervalSeconds, 150)
        XCTAssertEqual(apiCall.numRetries, 6)
        XCTAssertEqual(apiCall.retryIntervalSeconds, 0.2)
        XCTAssertEqual(apiCall.sendApiKeyAsQueryParam, true)
    }
    
    
    
    func testNodes() {
        let apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz"))
        
        XCTAssertNotNil(apiCall)
        XCTAssertNotNil(apiCall.nodes)
        XCTAssertNotEqual(0, apiCall.nodes.count)
        XCTAssertEqual(apiCall.nodes[0].host, "localhost")
        XCTAssertEqual(apiCall.nodes[0].port, "8108")
        XCTAssertEqual(apiCall.nodes[0].nodeProtocol, "http")
        
    }
    
    func testNearestNode() {
        let apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", nearestNode: Node(host: "nearest.host", port: "8109", nodeProtocol: "https")))
        
        XCTAssertNotNil(apiCall)
        XCTAssertNotNil(apiCall.nodes)
        XCTAssertNotNil(apiCall.nearestNode)
        XCTAssertEqual(apiCall.nearestNode?.host, "nearest.host")
        XCTAssertEqual(apiCall.nearestNode?.port, "8109")
        XCTAssertEqual(apiCall.nearestNode?.nodeProtocol, "https")
        
    }
    
    func testRequest() {
        let apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz"))
        
        let request = apiCall.prepareRequest(requestType: RequestType.get, endpoint: "health", body: nil, selectedNode: apiCall.nodes[0])
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.absoluteString, "http://localhost:8108/health")
        XCTAssertNil(request.httpBody)
        XCTAssertTrue(request.allHTTPHeaderFields?.isEmpty != nil)
        XCTAssertEqual(request.allHTTPHeaderFields?[APIKEYHEADERNAME], apiCall.apiKey)
        
    }
    
    func testSetNodeHealthCheck() {
        let apiCall = ApiCall(config: Configuration(nodes: [
            Node(host: "localhost", port: "8108", nodeProtocol: "http"),
            Node(host: "localhost", port: "8109", nodeProtocol: "http"),
        ], apiKey: "xyz"))
        
        let node1 = apiCall.setNodeHealthCheck(node: apiCall.nodes[0], isHealthy: HEALTHY)
        let node2 = apiCall.setNodeHealthCheck(node: apiCall.nodes[1], isHealthy: UNHEALTHY)
        
        XCTAssertEqual(node1.isHealthy, HEALTHY)
        XCTAssertEqual(node2.isHealthy, UNHEALTHY)
        XCTAssertNotNil(node1.lastAccessTimeStamp)
        XCTAssertNotNil(node2.lastAccessTimeStamp)
        
    }
    
    func testGetNextNode() {
        var apiCall = ApiCall(config: Configuration(nodes: [
            Node(host: "localhost", port: "8108", nodeProtocol: "http"),
            Node(host: "localhost", port: "8109", nodeProtocol: "http"),
        ], apiKey: "xyz"))
        
        var node = apiCall.getNextNode()
        XCTAssertEqual(node.isHealthy, HEALTHY)
        XCTAssertEqual(node.port, "8108")

        //Progresses to next healthy node
        node = apiCall.getNextNode()
        XCTAssertEqual(node.isHealthy, HEALTHY)
        XCTAssertEqual(node.port, "8109")
    }
    
}
