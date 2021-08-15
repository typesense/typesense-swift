//
//  ApiCallTests.swift
//  
//
//  Created by Sabesh Bharathi on 08/08/21.
//

import XCTest
@testable import Typesense

final class ApiCallTests: XCTestCase {
    func testHealth() {
        var apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz"))
        var expectation:XCTestExpectation? = expectation(description: "Check health of system")
        
        apiCall.get(endPoint: "health") { result in
            XCTAssertEqual(result, "{\"ok\":true}")
            expectation?.fulfill()
            expectation = nil
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
