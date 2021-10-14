import Foundation

let RESOURCEPATH = "/collections"

struct Collections {
    var apiCall: ApiCall
    
    init(config: Configuration) {
        apiCall = ApiCall(config: config)
    }
    
}
