import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif


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

    public func delete() async throws -> (CollectionResponse?, URLResponse?) {
        let (data, response) = try await apiCall.delete(endPoint: "\(RESOURCEPATH)/\(collectionName)")
        if let result = data {
            if let notExists = try? decoder.decode(ApiResponse.self, from: result) {
                throw ResponseError.collectionDoesNotExist(desc: notExists.message)
            }
            let fetchedCollection = try decoder.decode(CollectionResponse.self, from: result)
            return (fetchedCollection, response)
        }
        return (nil, response)
    }

    public func retrieve() async throws -> (CollectionResponse?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: "\(RESOURCEPATH)/\(collectionName)")
        if let result = data {
            if let notExists = try? decoder.decode(ApiResponse.self, from: result) {
                throw ResponseError.collectionDoesNotExist(desc: notExists.message)
            }
            let fetchedCollection = try decoder.decode(CollectionResponse.self, from: result)
            return (fetchedCollection, response)
        }
        return (nil, response)
    }

    public func synonyms() -> Synonyms {
        return Synonyms(config: self.config, collectionName: self.collectionName)
    }

    public func overrides() -> Overrides{
        return Overrides(apiCall:self.apiCall, collectionName: self.collectionName)
    }

    public func override(_ overrideId: String) -> Override{
        return Override(apiCall:self.apiCall, collectionName: self.collectionName, overrideId: overrideId)
    }
}
