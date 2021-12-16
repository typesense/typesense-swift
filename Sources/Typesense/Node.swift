public struct Node: CustomStringConvertible {
    var host: String
    var port: String
    var nodeProtocol: String
    var isHealthy: Bool = false
    var lastAccessTimeStamp: Int64 = 0
    
    public init(host: String, port: String, nodeProtocol: String) {
        self.host = host
        self.port = port
        self.nodeProtocol = nodeProtocol
    }
    
    public var description: String {
        return "Node: \(nodeProtocol)://\(host):\(port)"
    }
    
    public var healthStatus: String {
        return isHealthy ? "Healthy" : "Unhealthy"
    }
}
