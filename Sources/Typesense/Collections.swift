import Foundation

public struct Collections {
    var apiCall: ApiCall
    let RESOURCEPATH = "collections"
    
    public init(config: Configuration) {
        apiCall = ApiCall(config: config)
    }
    
    func create(schema: CollectionSchema) async throws -> (CollectionResponse?, Int?) {
        var schemaData: Data? = nil
    
        schemaData = try encoder.encode(schema)
            
        if let validSchema = schemaData {
            let (data, statusCode) = try await apiCall.post(endPoint: RESOURCEPATH, body: validSchema)
            if let result = data {
                let fetchedCollection = try decoder.decode(CollectionResponse.self, from: result)
                return (fetchedCollection, statusCode)
            }
        }
        return (nil, nil)
    }
    
    func retrieveAll() async throws -> ([CollectionResponse]?, Int?) {
        let (data, statusCode) = try await apiCall.get(endPoint: RESOURCEPATH)
        
        if let result = data {
            let fetchedCollections = try decoder.decode([CollectionResponse].self, from: result)
            return (fetchedCollections, statusCode)
        }
        return (nil, statusCode)
    }
}
