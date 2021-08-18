import Foundation

let RESOURCEPATH = "/collections"

struct Collections {
    var apiCall: ApiCall
    
    init(config: Configuration) {
        apiCall = ApiCall(config: config)
    }
    
    func create() -> String {
        return "Create"
    }
    
    func retrieve() -> String {
        return "Retrieve"
    }
}
