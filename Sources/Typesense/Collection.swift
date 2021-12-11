import Foundation

public struct Collection {
    var apiCall: ApiCall
    let RESOURCEPATH = "collections"
    var config: Configuration
    
    var collectionName: String
    
    public init(config: Configuration, collectionName: String) {
        apiCall = ApiCall(config: config)
        self.config = config
        self.collectionName = collectionName
    }
    
    public func documents() -> Documents {
        return Documents(config: self.config, collectionName: self.collectionName)
    }
    
    public func document(id: String) -> Document {
        return Document(config: self.config, collectionName: self.collectionName, id: id)
    }
    
    func delete() async throws -> (CollectionResponse?, Int?) {
        let (data, statusCode) = try await apiCall.delete(endPoint: "\(RESOURCEPATH)/\(collectionName)")
        if let result = data {
            let fetchedCollection = try decoder.decode(CollectionResponse.self, from: result)
            return (fetchedCollection, statusCode)
        }
        return (nil, statusCode)
    }
    
    func retrieve() async throws -> (CollectionResponse?, Int?) {
        let (data, statusCode) = try await apiCall.get(endPoint: "\(RESOURCEPATH)/\(collectionName)")
        if let result = data {
            let fetchedCollection = try decoder.decode(CollectionResponse.self, from: result)
            return (fetchedCollection, statusCode)
        }
        return (nil, statusCode)
    }
}
