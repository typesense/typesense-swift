import Foundation

let RESOURCEPATH = "/collections"

struct Collections {
    var apiCall: ApiCall
    
    init(config: Configuration) {
        apiCall = ApiCall(config: config)
    }
    
    mutating func create(schema: CollectionSchema) {
        var schemaData: Data? = nil
        do {
            schemaData = try encoder.encode(schema)
            apiCall.post(endPoint: "collections", body: schemaData!) { result in
                print(result as Any)
            }
        } catch {
            print("ERROR: Unable to resolve JSON from schema")
        }
    }
    
    mutating func retrieve() {
        apiCall.get(endPoint: "collections") { result in
            do {
                let fetchedCollections = try decoder.decode([Collection].self, from: result!)
            } catch {
                print("ERROR: Unable to resolve retrieved collections")
            }
            
        }
    }
}
