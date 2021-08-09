//
//  Node.swift
//  
//
//  Created by Sabesh Bharathi on 07/08/21.
//

import Foundation

struct Node: CustomStringConvertible {
    var host: String
    var port: String
    var nodeProtocol: String
    
    var description: String {
        return "Node: \(nodeProtocol)://\(host):\(port)"
    }
}
