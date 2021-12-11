import Foundation

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
    
    func delete() async throws -> (Data?, Int?) {
        let (data, statusCode) = try await apiCall.delete(endPoint: "\(RESOURCEPATH)/\(self.id)")
        return (data, statusCode)
    }
    
    
    func retrieve() async throws -> (Data?, Int?) {
        let (data, statusCode) = try await apiCall.get(endPoint: "\(RESOURCEPATH)/\(self.id)")
        return (data, statusCode)
    }
    
}
