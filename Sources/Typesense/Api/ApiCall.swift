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
    var logger: Logger
    
    init(config: Configuration) {
        self.apiKey = config.apiKey
        self.nodes = config.nodes
        self.nearestNode = config.nearestNode
        self.connectionTimeoutSeconds = config.connectionTimeoutSeconds
        self.healthcheckIntervalSeconds = config.healthcheckIntervalSeconds
        self.numRetries = config.numRetries
        self.retryIntervalSeconds = config.retryIntervalSeconds
        self.sendApiKeyAsQueryParam = config.sendApiKeyAsQueryParam
        self.logger = config.logger
        
        self.initializeMetadataForNodes()
    }
    
    //Various request types' implementation

    mutating func get(endPoint: String) async throws -> (Data?, Int?) {
        let (data, statusCode) = try await self.performRequest(requestType: RequestType.get, endpoint: endPoint)
        return (data, statusCode)
    }
    
    mutating func delete(endPoint: String) async throws -> (Data?, Int?) {
        let (data, statusCode) = try await self.performRequest(requestType: RequestType.delete, endpoint: endPoint)
        return (data, statusCode)
    }
    
    mutating func post(endPoint: String, body: Data) async throws -> (Data?, Int?) {
        let (data, statusCode) = try await self.performRequest(requestType: RequestType.post, endpoint: endPoint, body: body)
        return (data, statusCode)
    }
    
    mutating func put(endPoint: String, body: Data) async throws -> (Data?, Int?) {
        let (data, statusCode) = try await self.performRequest(requestType: RequestType.put, endpoint: endPoint, body: body)
        return (data, statusCode)
    }
    
    mutating func patch(endPoint: String, body: Data) async throws -> (Data?, Int?) {
        let (data, statusCode) = try await self.performRequest(requestType: RequestType.patch, endpoint: endPoint, body: body)
        return (data, statusCode)
    }
    
    //Actual API Call
    mutating func performRequest(requestType: RequestType, endpoint: String, body: Data? = nil) async throws -> (Data?, Int?) {
        let requestNumber = Date().millisecondsSince1970
        logger.log("Request #\(requestNumber): Performing \(requestType.rawValue) request: /\(endpoint)")
        
        for numTry in 1...self.numRetries + 1 {
            //Get next healthy node
            var selectedNode = self.getNextNode(requestNumber: requestNumber)
            logger.log("Request #\(requestNumber): Attempting \(requestType.rawValue) request: Try \(numTry) to \(selectedNode)/\(endpoint)")
        
            //Configure the request with URL and Headers
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
             
            let (data, response) = try await URLSession.shared.data(for: request)
        
            if let res = response as? HTTPURLResponse {
                if (res.statusCode >= 1 && res.statusCode <= 499) {
                    // Treat any status code > 0 and < 500 to be an indication that node is healthy
                    // We exclude 0 since some clients return 0 when request fails
                    selectedNode = setNodeHealthCheck(node: selectedNode, isHealthy: HEALTHY)
                }
                
                logger.log("Request \(requestNumber): Request to \(urlString) was made. Response Code was \(res.statusCode)")
                
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    //Return the data and status code for a 2xx response
                    return (data, res.statusCode)
                } else if (res.statusCode < 500) {
                    //For any response under code 500, throw the corresponding HTTP error
                    throw HTTPError.serverError(code: res.statusCode, desc: "error")
                } else {
                    //For all other response codes (>=500) throw custom error
                    throw HTTPError.serverError(code: res.statusCode, desc: "Server error!")
                }
                
                
            }
        }
        
        return (nil,nil)
    }
    
    //Bundles a URL Request
    func prepareRequest(requestType: RequestType, endpoint: String, body: Data? = nil, selectedNode: Node) -> URLRequest {
        
        let urlString = uriFor(endpoint: endpoint, node: selectedNode)
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        request.httpMethod = requestType.rawValue
        
        //Set the ApiKey Header
        request.setValue(self.apiKey, forHTTPHeaderField: APIKEYHEADERNAME)

        if let httpBody = body {
            //Set the following headers if a body is present
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //Set the body of the request
            request.httpBody = httpBody
        }
        
        return request
    }
    
    //Get URL for a node combined with it's end point
    func uriFor(endpoint: String, node: Node) -> String {
        return "\(node.nodeProtocol)://\(node.host):\(node.port)/\(endpoint)"
    }
    
    //Get the next healthy node from the given nodes
    mutating func getNextNode(requestNumber: Int64 = 0) -> Node {
        
        //Check if nearest node exists and is healthy
        if let existingNearestNode = nearestNode {
            logger.log("Request #\(requestNumber): Nearest Node has health \(existingNearestNode.healthStatus)")
            
            if(existingNearestNode.isHealthy || self.nodeDueForHealthCheck(node: existingNearestNode, requestNumber: requestNumber)) {
                logger.log("Request #\(requestNumber): Updated current node to \(existingNearestNode)")
                return existingNearestNode
            }
            
            logger.log("Request #\(requestNumber): Falling back to individual nodes")
        }
        
        //Fallback to nodes as usual
        logger.log("Request #\(requestNumber): Listing health of nodes")
        let _ = self.nodes.map { node in
            logger.log("Health of \(node) is \(node.healthStatus)")
        }
        
        var candidateNode = nodes[0]
        
        for _ in 0...nodes.count {
            currentNodeIndex = (currentNodeIndex + 1) % nodes.count
            candidateNode = self.nodes[currentNodeIndex]
            
            if(candidateNode.isHealthy || self.nodeDueForHealthCheck(node: candidateNode, requestNumber: requestNumber)) {
                logger.log("Request #\(requestNumber): Updated current node to \(candidateNode)")
                return candidateNode
            }
        }
        
        return self.nodes[currentNodeIndex]
    }
    
    func nodeDueForHealthCheck(node: Node, requestNumber: Int64 = 0) -> Bool {
        let isDueForHealthCheck = Date().millisecondsSince1970 - node.lastAccessTimeStamp > (self.healthcheckIntervalSeconds * 1000)
        if (isDueForHealthCheck) {
            logger.log("Request #\(requestNumber): \(node) has exceeded healtcheckIntervalSeconds of \(self.healthcheckIntervalSeconds). Adding it back into rotation.")
        }
        
        return isDueForHealthCheck
    }
    
    //Set's Node's health status
    func setNodeHealthCheck(node: Node, isHealthy: Bool) -> Node {
        var thisNode = node
        thisNode.isHealthy = isHealthy
        thisNode.lastAccessTimeStamp = Date().millisecondsSince1970
        return thisNode
    }
    
    //Initializes a node's health status and last access time
    mutating func initializeMetadataForNodes() {
        if let existingNearestNode = self.nearestNode {
            self.nearestNode = self.setNodeHealthCheck(node: existingNearestNode, isHealthy: HEALTHY)
        }
        
        for i in 0..<self.nodes.count {
            self.nodes[i] = self.setNodeHealthCheck(node: self.nodes[i], isHealthy: HEALTHY)
        }
    }
    
}
