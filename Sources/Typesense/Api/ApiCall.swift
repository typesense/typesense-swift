import Foundation


let APIKEYHEADERNAME = "X-TYPESENSE-API-KEY"
let HEALTHY = true
let UNHEALTHY = false

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
        
        self.initializeMetadataForNodes()
    }
    
    

    mutating func get(endPoint: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        self.performRequest(requestType: RequestType.get, endpoint: endPoint, completionHandler: completionHandler)
    }
    
    mutating func delete(endPoint: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        self.performRequest(requestType: RequestType.delete, endpoint: endPoint, completionHandler: completionHandler)
    }
    
    mutating func post(endPoint: String, body: Data, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        self.performRequest(requestType: RequestType.post, endpoint: endPoint, body: body, completionHandler: completionHandler)
    }
    
    mutating func put(endPoint: String, body: Data, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        self.performRequest(requestType: RequestType.put, endpoint: endPoint, body: body, completionHandler: completionHandler)
    }
    
    mutating func patch(endPoint: String, body: Data, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        self.performRequest(requestType: RequestType.patch, endpoint: endPoint, body: body, completionHandler: completionHandler)
    }
    
    mutating func performRequest(requestType: RequestType, endpoint: String, body: Data? = nil, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        let requestNumber = Date().millisecondsSince1970
        print("Request #\(requestNumber): Performing \(requestType.rawValue) request: /\(endpoint)")
        
        for numTry in 1...self.numRetries + 1 {
            var selectedNode = self.getNextNode(requestNumber: requestNumber)
            print("Request #\(requestNumber): Attempting \(requestType.rawValue) request: Try \(numTry) to \(selectedNode)/\(endpoint)")
            
            let urlString = uriFor(endpoint: endpoint, node: selectedNode)
            let url = URL(string: urlString)
            
            let requestHeaders: [String : String] = [APIKEYHEADERNAME: self.apiKey]
            
            var request = URLRequest(url: url!)
            request.allHTTPHeaderFields = requestHeaders
            request.httpMethod = requestType.rawValue

            if let httpBody = body {
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = httpBody
            }
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let res = response as? HTTPURLResponse {
                    if (res.statusCode >= 1 && res.statusCode <= 499) {
                        // Treat any status code > 0 and < 500 to be an indication that node is healthy
                        // We exclude 0 since some clients return 0 when request fails
                        selectedNode.isHealthy = HEALTHY
                        selectedNode.lastAccessTimeStamp = Date().millisecondsSince1970
                    }
                    
                    if (res.statusCode >= 200 && res.statusCode <= 300) {
                        //Pass the data and response to completion handler for a 2xx response
                        completionHandler(data, response, nil)
                    } else if (res.statusCode < 500) {
                        //For any response but 500, trigger the completion handler for a static error
                        completionHandler(data, response, nil)
                    }
                    
                    print("Request \(requestNumber): Request to \(urlString) was made. Response Code was \(res.statusCode)")
                }
                
                if let existingError = error {
                    //An error is thrown if there is no response, and sequence is retried.
                    selectedNode.isHealthy = UNHEALTHY
                    selectedNode.lastAccessTimeStamp = Date().millisecondsSince1970
                    print("Request \(requestNumber): Request to \(urlString) failed due to error: \(existingError.localizedDescription)")
                    completionHandler(nil, nil, error)
                }
            }.resume()
            
            break
            
        }
    }
    
    
    func uriFor(endpoint: String, node: Node) -> String {
        return "\(node.nodeProtocol)://\(node.host):\(node.port)/\(endpoint)"
    }
    
    mutating func getNextNode(requestNumber: Int64 = 0) -> Node {
        
        //Check if nearest node exists and is healthy
        if let existingNearestNode = nearestNode {
            print("Request #\(requestNumber): Nearest Node has health \(existingNearestNode.healthStatus)")
            
            if(existingNearestNode.isHealthy || self.nodeDueForHealthCheck(node: existingNearestNode, requestNumber: requestNumber)) {
                print("Request #\(requestNumber): Updated current node to \(existingNearestNode)")
                return existingNearestNode
            }
            
            print("Request #\(requestNumber): Falling back to individual nodes")
        }
        
        //Fallback to nodes as usual
        print("Request #\(requestNumber): Listing health of nodes")
        let _ = self.nodes.map { node in
            print("Health of \(node) is \(node.healthStatus)")
        }
        
        var candidateNode = nodes[0]
        
        for _ in 0...nodes.count {
            currentNodeIndex = (currentNodeIndex + 1) % nodes.count
            candidateNode = self.nodes[currentNodeIndex]
            
            if(candidateNode.isHealthy || self.nodeDueForHealthCheck(node: candidateNode, requestNumber: requestNumber)) {
                print("Request #\(requestNumber): Updated current node to \(candidateNode)")
                return candidateNode
            }
        }
        
        return candidateNode
    }
    
    func nodeDueForHealthCheck(node: Node, requestNumber: Int64 = 0) -> Bool {
        let isDueForHealthCheck = Date().millisecondsSince1970 - node.lastAccessTimeStamp > (self.healthcheckIntervalSeconds * 1000)
        if (isDueForHealthCheck) {
            print("Request #\(requestNumber): \(node) has exceeded healtcheckIntervalSeconds of \(self.healthcheckIntervalSeconds). Adding it back into rotation.")
        }
        
        return isDueForHealthCheck
    }
    
    func setNodeHealthCheck(node: Node, isHealthy: Bool) -> Node {
        var thisNode = node
        thisNode.isHealthy = isHealthy
        thisNode.lastAccessTimeStamp = Date().millisecondsSince1970
        return thisNode
    }
    
    mutating func initializeMetadataForNodes() {
        if let existingNearestNode = self.nearestNode {
            self.nearestNode = self.setNodeHealthCheck(node: existingNearestNode, isHealthy: HEALTHY)
        }
        
        for i in 0..<self.nodes.count {
            self.nodes[i] = self.setNodeHealthCheck(node: self.nodes[i], isHealthy: HEALTHY)
        }
    }
    
}
