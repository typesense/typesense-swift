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

    public func update(schema: CollectionUpdateSchema) async throws -> (CollectionUpdateSchema?, URLResponse?) {
        let schemaData = try encoder.encode(schema)
        let (data, response) = try await apiCall.patch(endPoint: endpointPath(), body: schemaData)
        if let result = data {
            let updatedSchema = try decoder.decode(CollectionUpdateSchema.self, from: result)
            return (updatedSchema, response)
        }
        return (nil, response)
    }

    private func endpointPath() throws -> String {
        return "\(Collections.RESOURCEPATH)/\(try collectionName.encodeURL())"
    }
}
