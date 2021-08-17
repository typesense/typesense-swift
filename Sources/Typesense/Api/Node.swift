struct Node: CustomStringConvertible {
    var host: String
    var port: String
    var nodeProtocol: String
    
    var description: String {
        return "Node: \(nodeProtocol)://\(host):\(port)"
    }
}
