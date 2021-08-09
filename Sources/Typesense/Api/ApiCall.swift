//
//  File.swift
//  
//
//  Created by Sabesh Bharathi on 07/08/21.
//

import Foundation


struct ApiCall {
    var nodes: [Node]
    var apiKey: String
    var nearestNode: Node? = nil
    var connectionTimeoutSeconds: Int = 10
    var healthcheckIntervalSeconds: Int = 15
    var numRetries: Int = 3
    var retryIntervalSeconds: Float = 0.1
    var sendApiKeyAsQueryParam: Bool = false
    var currentNodeIndex = -1
    
    init(config: Configuration) {
        self.apiKey = config.apiKey
        self.nodes = config.nodes
        self.nearestNode = config.nearestNode
        self.connectionTimeoutSeconds = config.connectionTimeoutSeconds
        self.healthcheckIntervalSeconds = config.healthcheckIntervalSeconds
        self.numRetries = config.numRetries
        self.retryIntervalSeconds = config.retryIntervalSeconds
        self.sendApiKeyAsQueryParam = config.sendApiKeyAsQueryParam
    }
    
    
    mutating func performRequest(requestType: RequestType, endpoint: String) -> String {
        let requestNumber = Date().millisecondsSince1970
        print("Request #\(requestNumber): Performing \(requestType.rawValue.uppercased()) request: \(endpoint)")
        
        
        for numTry in 1...self.numRetries + 1 {
            let selectedNode = self.getNextNode(requestNumber: requestNumber)
            print("Request \(requestNumber): Attempting \(requestType.rawValue.uppercased()) request: Try \(numTry) to Node \(selectedNode)")
     
//          URLSession needs to be made with given parameters and endpoint.
            
//            let session = URLSession.shared
//            let urlString = uriFor(endpoint: endpoint, node: selectedNode)
//            let url = URL(string: urlString)
//            _ = session.dataTask(with: url!) { data, response, url in
//                print(data)
//                print(response)
//                print(error)
//            }
            
            
        }
        
        return "Request #0: Performing \(requestType.rawValue.uppercased()) request: \(endpoint)"
    }
    
    
    func uriFor(endpoint: String, node: Node) -> String {
        return "\(node.nodeProtocol)://\(node.host):\(node.port)/\(endpoint)"
    }
    
    mutating func getNextNode(requestNumber: Int64 = 0) -> Node {
        if let existingNearestNode = nearestNode {
            print("Nearest Node exists. Updating current node to node \(existingNearestNode)")
            return self.nearestNode!
        }
        
        print("Nearest Node not found, falling back to nodes")
        
        for _ in 0...nodes.count {
            currentNodeIndex = (currentNodeIndex + 1) % nodes.count
            let candidateNode = self.nodes[currentNodeIndex]
            print("Falling back to node \(candidateNode)")
            return candidateNode
        }
        
        return nodes[0]
    }
    
}
