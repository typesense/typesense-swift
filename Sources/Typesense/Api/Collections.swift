import Foundation

let RESOURCEPATH = "/collections"

struct Collections {
    var apiCall: ApiCall
    
    init(config: Configuration) {
        apiCall = ApiCall(config: config)
    }
    
    mutating func create(schema: CollectionSchema, completionHandler: @escaping (String) -> ()){
//        let jsonData = try! JSONEncoder().encode(schema)
//        let jsonString = String(data: jsonData, encoding: .utf8)
//        apiCall.post(endPoint: RESOURCEPATH, body: jsonData) { result in
//            completionHandler(result)
//        }
    }
    
    func retrieve() -> String {
        return "Retrieve"
    }
}
