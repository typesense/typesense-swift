import Foundation

struct Client {
    
    var configuration: Configuration
    var apiCall: ApiCall
    var collections: Collections
    
    init(config: Configuration) {
        self.configuration = config
        self.apiCall = ApiCall(config: config)
        self.collections = Collections(config: config)
    }
}
