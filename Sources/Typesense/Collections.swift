import Foundation

let RESOURCEPATH = "/collections"

public struct Collections {
    var apiCall: ApiCall
    
    public init(config: Configuration) {
        apiCall = ApiCall(config: config)
    }
    
}
