import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif


public struct ApiKeys {
    var apiCall: ApiCall
    let RESOURCEPATH = "keys"

    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }

    public func create(_ keySchema: ApiKeySchema) async throws -> (ApiKey?, URLResponse?) {
        var schemaData: Data? = nil

        schemaData = try encoder.encode(keySchema)

        if let validSchema = schemaData {
            let (data, response) = try await apiCall.post(endPoint: "\(RESOURCEPATH)", body: validSchema)
            if let result = data {
                let keyResponse = try decoder.decode(ApiKey.self, from: result)
                return (keyResponse, response)
            }
        }

        return (nil, nil)
    }

    public func retrieve(id: Int64) async throws -> (ApiKey?, URLResponse?) {

        let (data, response) = try await apiCall.get(endPoint: "\(RESOURCEPATH)/\(id)")
        if let result = data {
            let keyResponse = try decoder.decode(ApiKey.self, from: result)
            return (keyResponse, response)
        }

        return (nil, nil)
    }

    public func retrieve() async throws -> (ApiKeysResponse?, URLResponse?) {

        let (data, response) = try await apiCall.get(endPoint: "\(RESOURCEPATH)")
        if let result = data {
            let keyResponse = try decoder.decode(ApiKeysResponse.self, from: result)
            return (keyResponse, response)
        }

        return (nil, nil)
    }

    public func delete(id: Int64) async throws -> (Data?, URLResponse?) {

        let (data, response) = try await apiCall.delete(endPoint: "\(RESOURCEPATH)/\(id)")
        return (data, response)
    }
}
