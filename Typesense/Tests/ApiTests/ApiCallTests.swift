//
//  ApiCallTests.swift
//  
//
//  Created by Sabesh Bharathi on 08/08/21.
//

import XCTest
@testable import Typesense

final class ApiCallTests: XCTestCase {
    func testGetRequestDemo() {
        var apiCall = ApiCall(config: Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz"))
        
        let result: String = apiCall.performRequest(requestType: RequestType.get, endpoint: "/collections")
        
        XCTAssertEqual(result, "Request #0: Performing GET request: /collections")
    }
}
