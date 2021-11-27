import Foundation

public struct Documents {
    var apiCall: ApiCall
    var collectionName: String?
    let RESOURCEPATH: String
    
    public init(config: Configuration, collectionName: String) {
        apiCall = ApiCall(config: config)
        self.collectionName = collectionName
        self.RESOURCEPATH = "collections/\(collectionName)/documents"
    }
    
    func create(document: Data) async throws -> (Data?, Int?) {
        let (data, statusCode) = try await apiCall.post(endPoint: RESOURCEPATH, body: document)
        return (data, statusCode)
    }
    
    func upsert(document: Data) async throws -> (Data?, Int?) {
        let upsertAction = URLQueryItem(name: "action", value: "upsert")
        let (data, statusCode) = try await apiCall.post(endPoint: RESOURCEPATH, body: document, queryParameters: [upsertAction])
        return (data, statusCode)
    }
    
    func delete(id: String) async throws -> (Data?, Int?) {
        let (data, statusCode) = try await apiCall.delete(endPoint: "\(RESOURCEPATH)/\(id)")
        return (data, statusCode)
    }
    
    func retrieve(id: String) async throws -> (Data?, Int?) {
        let (data, statusCode) = try await apiCall.get(endPoint: "\(RESOURCEPATH)/\(id)")
        return (data, statusCode)
    }
}
