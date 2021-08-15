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
        
        apiCall.performRequest(requestType: RequestType.get, endpoint: "health") { result in
            XCTAssertEqual(result, "{\"ok\":true}")
        }
    }
}
