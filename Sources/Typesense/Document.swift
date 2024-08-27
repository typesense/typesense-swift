import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif


public struct Document {
    var apiCall: ApiCall
    var collectionName: String
    var id: String

    init(apiCall: ApiCall, collectionName: String, id: String) {
        self.apiCall = apiCall
        self.collectionName = collectionName
        self.id = id
    }

    public func delete() async throws -> (Data?, URLResponse?) {
        let (data, response) = try await apiCall.delete(endPoint: endpointPath())
        return (data, response)
    }

    public func retrieve() async throws -> (Data?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath())
        return (data, response)
    }

    public func update(newDocument: Data, options: DocumentIndexParameters? = nil) async throws -> (Data?, URLResponse?) {
        let queryParams = try createURLQuery(forSchema: options)
        let (data, response) = try await apiCall.patch(endPoint: endpointPath(), body: newDocument, queryParameters: queryParams)
        return (data, response)
    }

    private func endpointPath() throws -> String {
        return try "\(Collections.RESOURCEPATH)/\(collectionName.encodeURL())/documents/\(id.encodeURL())"
    }
}
