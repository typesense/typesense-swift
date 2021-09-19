import Foundation

struct Collections {
    var apiCall: ApiCall
    
    init(config: Configuration) {
        apiCall = ApiCall(config: config)
    }
    
    mutating func create(schema: CollectionSchema, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        var schemaData: Data? = nil
        do {
            schemaData = try encoder.encode(schema)
            apiCall.post(endPoint: "collections", body: schemaData!) { result, response, error in
                completionHandler(result, response, error)
            }
        } catch {
            print("ERROR: Unable to resolve JSON from schema")
        }
    }
    
    mutating func retrieveAll(completionHandler: @escaping ([Collection]?, URLResponse?, Error?) -> ()) {
        apiCall.get(endPoint: "collections") { result, response, error in
            do {
                let fetchedCollections = try decoder.decode([Collection].self, from: result!)
                completionHandler(fetchedCollections, response, error)
            } catch {
                print("ERROR: Unable to resolve retrieved collections")
                completionHandler(nil, response, error)
            }
            
        }
    }
    
    mutating func delete(name: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        apiCall.delete(endPoint: "collections/\(name)") { result, response, error in
            completionHandler(result, response, error)
        }
    }
    
    mutating func retrieve(name: String, completionHandler: @escaping (Collection?, URLResponse?, Error?) -> ()) {
        apiCall.get(endPoint: "collections/\(name)") { result, response, error in
            do {
                let fetchedCollection = try decoder.decode(Collection.self, from: result!)
                completionHandler(fetchedCollection, response, error)
            } catch {
                print("ERROR: Unable to resolve retrieved collection")
                completionHandler(nil, response, error)
            }
        }
    }
    
    
}
