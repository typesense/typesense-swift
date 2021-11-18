import Foundation

public struct Client {
    
    var configuration: Configuration
    var apiCall: ApiCall
    public var collections: Collections
    
    public init(config: Configuration) {
        self.configuration = config
        self.apiCall = ApiCall(config: config)
        self.collections = Collections(config: config)
    }
}
