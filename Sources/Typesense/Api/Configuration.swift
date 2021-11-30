import Foundation

struct Configuration {
    
    //Required Config
    var nodes: [Node]
    var apiKey: String
    
    //Optional Config
    var nearestNode: Node? = nil
    var connectionTimeoutSeconds: Int = 10
    var healthcheckIntervalSeconds: Int = 15
    var numRetries: Int = 3
    var retryIntervalSeconds: Float = 0.1
    var sendApiKeyAsQueryParam: Bool = false
    var cacheSearchResultsForSeconds: Int = 0
    var useServerSideSearchCache: Bool = false
    
    //Quick configurations
    init(nodes: [Node], apiKey: String) {
        self.nodes = nodes
        self.apiKey = apiKey
    }
    
    init(nodes: [Node], apiKey: String, connectionTimeoutSeconds: Int = 10, nearestNode: Node?) {
        self.nodes = nodes
        self.apiKey = apiKey
        self.connectionTimeoutSeconds = connectionTimeoutSeconds
        self.nearestNode = nearestNode
    }
    
    //Advanced configurations
    init(nodes: [Node], apiKey: String, connectionTimeoutSeconds: Int = 10, nearestNode: Node? = nil, healthcheckIntervalSeconds: Int = 15, numRetries: Int = 3, retryIntervalSeconds: Float = 0.1, sendApiKeyAsQueryParam: Bool = false, cacheSearchResultsForSeconds: Int = 0, useServerSideSearchCache: Bool = false) {
        self.nodes = nodes
        self.apiKey = apiKey
        self.connectionTimeoutSeconds = connectionTimeoutSeconds
        self.nearestNode = nearestNode
        self.healthcheckIntervalSeconds = healthcheckIntervalSeconds
        self.numRetries = numRetries
        self.retryIntervalSeconds = retryIntervalSeconds
        self.sendApiKeyAsQueryParam = sendApiKeyAsQueryParam
        self.cacheSearchResultsForSeconds = cacheSearchResultsForSeconds
        self.useServerSideSearchCache = useServerSideSearchCache
    }
 
}
