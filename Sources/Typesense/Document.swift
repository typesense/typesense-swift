import Foundation
import FoundationNetworking


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
        if let result = data {
            if let responseErr = try? decoder.decode(ApiResponse.self, from: result) {
                if (responseErr.message == "Not Found") {
                    throw ResponseError.invalidCollection(desc: "Collection \(self.collectionName) \(responseErr.message)")
                }
                throw ResponseError.documentDoesNotExist(desc: responseErr.message)
            }
        }
        return (data, response)
    }

    public func retrieve() async throws -> (Data?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: "\(RESOURCEPATH)/\(self.id)")
        if let result = data {
            if let responseErr = try? decoder.decode(ApiResponse.self, from: result) {
                if (responseErr.message == "Not Found") {
                    throw ResponseError.invalidCollection(desc: "Collection \(self.collectionName) \(responseErr.message)")
                }
                throw ResponseError.documentDoesNotExist(desc: responseErr.message)
            }
        }
        return (data, response)
    }

    public func update(newDocument: Data) async throws -> (Data?, URLResponse?) {
        let (data, response) = try await apiCall.patch(endPoint: "\(RESOURCEPATH)/\(self.id)", body: newDocument)
        if let result = data {
            if let responseErr = try? decoder.decode(ApiResponse.self, from: result) {
                if (responseErr.message == "Not Found") {
                    throw ResponseError.invalidCollection(desc: "Collection \(self.collectionName) \(responseErr.message)")
                }
                throw ResponseError.documentDoesNotExist(desc: responseErr.message)
            }
        }
        return (data, response)
    }

}
