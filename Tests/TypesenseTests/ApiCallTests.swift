import XCTest

@testable import Typesense

final class A_ApiCallTests: XCTestCase {

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

    func testNodesWithURL() {
        let apiCall = ApiCall(config: Configuration(nodes: [Node(url: "http://localhost:8108")], apiKey: "xyz"))

        XCTAssertNotNil(apiCall)
        XCTAssertNotNil(apiCall.nodes)
        XCTAssertNotEqual(0, apiCall.nodes.count)
        XCTAssertEqual(apiCall.nodes[0].url, "http://localhost:8108")

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

        do {
            let request = try apiCall.prepareRequest(requestType: RequestType.get, endpoint: "health", body: nil, selectedNode: apiCall.nodes[0])

            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.absoluteString, "http://localhost:8108/health")
            XCTAssertNil(request.httpBody)
            XCTAssertTrue(request.allHTTPHeaderFields?.isEmpty != nil)
            XCTAssertEqual(request.allHTTPHeaderFields?[APIKEYHEADERNAME], apiCall.apiKey)
        } catch (let error) {
            print(error.localizedDescription)
        }

    }

    func testRequestWithNodeURL() {
        let apiCall = ApiCall(config: Configuration(nodes: [Node(url: "http://localhost:8108")], apiKey: "xyz"))

        do {
            let request = try apiCall.prepareRequest(requestType: RequestType.get, endpoint: "health", body: nil, selectedNode: apiCall.nodes[0])

            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.absoluteString, "http://localhost:8108/health")
            XCTAssertNil(request.httpBody)
            XCTAssertTrue(request.allHTTPHeaderFields?.isEmpty != nil)
            XCTAssertEqual(request.allHTTPHeaderFields?[APIKEYHEADERNAME], apiCall.apiKey)
        } catch (let error) {
            print(error.localizedDescription)
        }

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
        let apiCall = ApiCall(config: Configuration(nodes: [
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

    //Integration Test - Requires Typesense Server
    func testServerHealth() async {
        let apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true)))

        do {
            let (data, response) = try await apiCall.get(endPoint: "health")
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            let health = try decoder.decode(HealthStatus.self, from: validData)
            XCTAssertEqual(health.ok, true)
        } catch (let error) {
            print(error.localizedDescription)
        }
    }


    func testApiCallThrowClientError() async {
        let apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true)))
        do {
            let _ = try await apiCall.delete(endPoint: "health") // will response a 404
        } catch HTTPError.clientError(let code, _) {
            XCTAssertEqual(404, code)
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testApiCallThrowServerError() async {
        // using an invalid url to force an error
        let apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "12345678910", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true)))
        do {
            let _ = try await apiCall.delete(endPoint: "health")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error)
            XCTAssertTrue(true)
        }
    }

}
