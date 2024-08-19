import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif


public struct Document {
    var apiCall: ApiCall
    var collectionName: String
    var id: String
    let RESOURCEPATH: String

    public init(config: Configuration, collectionName: String, id: String) {
        apiCall = ApiCall(config: config)
        self.collectionName = collectionName
        self.id = id
        self.RESOURCEPATH = "collections/\(collectionName)/documents"
    }

    public func delete() async throws -> (Data?, URLResponse?) {
        let (data, response) = try await apiCall.delete(endPoint: "\(RESOURCEPATH)/\(self.id)")
        return (data, response)
    }

    public func retrieve() async throws -> (Data?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: "\(RESOURCEPATH)/\(self.id)")
        return (data, response)
    }

    public func update(newDocument: Data) async throws -> (Data?, URLResponse?) {
        let (data, response) = try await apiCall.patch(endPoint: "\(RESOURCEPATH)/\(self.id)", body: newDocument)
        return (data, response)
    }

}
