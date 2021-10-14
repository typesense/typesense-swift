import XCTest
@testable import Typesense

final class ApiCallTests: XCTestCase {
    func testHealth() {
            var apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz"))
            var expectation:XCTestExpectation? = expectation(description: "Check health of system")
            
            apiCall.get(endPoint: "health") { result, response, error in
                do {
                    if let healthRes = result {
                        let jsonRes = try decoder.decode(HealthStatus.self, from: healthRes)
                        XCTAssertTrue(jsonRes.ok)
                        expectation?.fulfill()
                        expectation = nil
                    } else {
                        print("Response data was nil")
                    }
                } catch {
                    print("Could not resolve health status from response")
                }
                
            }
            
            waitForExpectations(timeout: 5, handler: nil)
        }
    
    func testHTTP200() {
        var apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz"))
        var expectation:XCTestExpectation? = expectation(description: "Check HTTP 200 Status")
        
        //Test health - should return 200 if healthy
        apiCall.get(endPoint: "health") { result, response, error in
            do {
                if let healthRes = result {
                    let jsonRes = try decoder.decode(HealthStatus.self, from: healthRes)
                    XCTAssertTrue(jsonRes.ok)
                    XCTAssertNil(error)
                    
                    if let res = response as? HTTPURLResponse {
                        //Check 200 ok
                        XCTAssertEqual(res.statusCode, 200)
                    }
                    expectation?.fulfill()
                    expectation = nil
                } else {
                    print("Response data was nil")
                }
                
            } catch {
                print("Could not resolve health status from response")
            }
            
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testHTTP404() {
        var apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz"))
        var expectation:XCTestExpectation? = expectation(description: "Check HTTP 404 Status")
        
        //Test for a random url - /randomURL that doesn't exist
        apiCall.get(endPoint: "randomURL") { result, response, error in
            do {
                if let notFoundRes = result {
                    let jsonRes = try decoder.decode(ApiResponse.self, from: notFoundRes)
                    XCTAssertEqual(jsonRes.message, "Not Found")
                    XCTAssertNil(error)
                    
                    if let res = response as? HTTPURLResponse {
                        //Check 404 not found
                        XCTAssertEqual(res.statusCode, 404)
                    }
                    expectation?.fulfill()
                    expectation = nil
                } else {
                    print("Response data was nil")
                }
                
            } catch {
                print("Could not resolve APIResponse type from given response")
            }
            
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testHTTP401() {
        //Initialize with a bad api key
        var apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "abc"))
        var expectation:XCTestExpectation? = expectation(description: "Check HTTP 401 Status")
        
        apiCall.get(endPoint: "collections") { result, response, error in
            do {
                if let notAuthRes = result {
                    let jsonRes = try decoder.decode(ApiResponse.self, from: notAuthRes)
                    //Check if bad api key fails while trying to access /collections
                    XCTAssertEqual(jsonRes.message, "Forbidden - a valid `x-typesense-api-key` header must be sent.")
                    XCTAssertNil(error)
                    
                    if let res = response as? HTTPURLResponse {
                        //Check 401 unauthorized
                        XCTAssertEqual(res.statusCode, 401)
                    }
                    expectation?.fulfill()
                    expectation = nil
                } else {
                    print("Response data was nil")
                }
            } catch {
                print("Could not resolve APIResponse type from given response")
            }
            
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testServerNotFound() {
        //Initialize unknown node (port 8000)
        var apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8000", nodeProtocol: "http")], apiKey: "xyz"))
        var expectation:XCTestExpectation? = expectation(description: "Check if Server could be found")
        
        apiCall.get(endPoint: "health") { result, response, error in
            
            if let existingErr = error {
                let errorMessage = existingErr.localizedDescription
                //There's no response, just an error message
                XCTAssertEqual(errorMessage, "Could not connect to the server.")
                XCTAssertNil(result)
                XCTAssertNil(response)
                expectation?.fulfill()
                expectation = nil
            } else {
                print("No Error triggered")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRetries() {
        var apiCall = ApiCall(config: Configuration(nodes: [
            Node(host: "localhost", port: "8108", nodeProtocol: "http"),
            Node(host: "localhost", port: "8109", nodeProtocol: "http"),
            Node(host: "localhost", port: "8110", nodeProtocol: "http")], apiKey: "xyz"))
        var expectation:XCTestExpectation? = expectation(description: "Check retries")
        
        apiCall.get(endPoint: "health") { result, response, error in
            do {
                if let healthRes = result {
                    let jsonRes = try decoder.decode(HealthStatus.self, from: healthRes)
                    XCTAssertTrue(jsonRes.ok)
                    expectation?.fulfill()
                    expectation = nil
                } else {
                    print("Response data was nil")
                }
            } catch {
                print("Could not resolve health status from response")
            }
            
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
