public struct Node: CustomStringConvertible {
    var host: String?
    var port: String?
    var nodeProtocol: String?
    var url: String?
    var isHealthy: Bool = false
    var lastAccessTimeStamp: Int64 = 0

    public init(host: String? = nil, port: String? = nil, nodeProtocol: String? = nil, url: String? = nil) {
        if url == nil && (host == nil || port == nil || nodeProtocol == nil) {
            fatalError("Node `url` or `nodeProtocol` and `host` and `port` must be set!")
        }
        self.host = host
        self.port = port
        self.nodeProtocol = nodeProtocol
        self.url = url
    }

    public var description: String {
        if let url = self.url {
            return "Node: \(url)"
        }
        return "Node: \(nodeProtocol!)://\(host!):\(port!)"
    }

    public var healthStatus: String {
        return isHealthy ? "Healthy" : "Unhealthy"
    }
}
