import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif


public struct Collection {
    var apiCall: ApiCall
    var collectionName: String

    init(apiCall: ApiCall, collectionName: String) {
        self.apiCall = apiCall
        self.collectionName = collectionName
    }

    public func documents() -> Documents {
        return Documents(apiCall: apiCall, collectionName: self.collectionName)
    }

    public func document(id: String) -> Document {
        return Document(apiCall: apiCall, collectionName: self.collectionName, id: id)
    }

    public func delete() async throws -> (CollectionResponse?, URLResponse?) {
        let (data, response) = try await apiCall.delete(endPoint: endpointPath())
        if let result = data {
            let fetchedCollection = try decoder.decode(CollectionResponse.self, from: result)
            return (fetchedCollection, response)
        }
        return (nil, response)
    }

    public func retrieve() async throws -> (CollectionResponse?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath())
        if let result = data {
            let fetchedCollection = try decoder.decode(CollectionResponse.self, from: result)
            return (fetchedCollection, response)
        }
        return (nil, response)
    }

    public func synonyms() -> Synonyms {
        return Synonyms(apiCall: apiCall, collectionName: self.collectionName)
    }

    public func overrides() -> Overrides{
        return Overrides(apiCall: self.apiCall, collectionName: self.collectionName)
    }

    public func override(_ overrideId: String) -> Override{
        return Override(apiCall: self.apiCall, collectionName: self.collectionName, overrideId: overrideId)
    }

    private func endpointPath() throws -> String {
        return "\(Collections.RESOURCEPATH)/\(try collectionName.encodeURL())"
    }
}
