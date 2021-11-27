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
    
    mutating func delete() async -> (Data?, Int?) {
        do {
            let (data, statusCode) = try await apiCall.delete(endPoint: "\(RESOURCEPATH)/\(collectionName)")
            return (data, statusCode)
        } catch (let error) {
            print(error.localizedDescription)
        }
        return (nil, nil)
    }
    
    mutating func retrieve() async -> (CollectionResponse?, Int?) {
        do {
            let (data, statusCode) = try await apiCall.get(endPoint: "\(RESOURCEPATH)/\(collectionName)")
            if let result = data {
                let fetchedCollection = try decoder.decode(CollectionResponse.self, from: result)
                return (fetchedCollection, statusCode)
            }
            return (nil, statusCode)
        } catch (let error) {
            print(error.localizedDescription)
        }
        return (nil, nil)
    }
}
