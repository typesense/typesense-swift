import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct Alias {
    var apiCall: ApiCall
    let RESOURCEPATH = "aliases"

    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }

    public func upsert(name: String, collection: CollectionAliasSchema) async throws -> (CollectionAlias?, URLResponse?) {
        let schemaData = try encoder.encode(collection)
        let (data, response) = try await apiCall.put(endPoint: endpointPath(name), body: schemaData)
        if let result = data {
            let alias = try decoder.decode(CollectionAlias.self, from: result)
            return (alias, response)
        }
        return (nil, response)
    }

    public func retrieve(name: String) async throws -> (CollectionAlias?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath(name))
        if let result = data {
            let alias = try decoder.decode(CollectionAlias.self, from: result)
            return (alias, response)
        }
        return (nil, response)
    }

    public func retrieve() async throws -> (CollectionAliasesResponse?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath())
        if let result = data {
            let aliases = try decoder.decode(CollectionAliasesResponse.self, from: result)
            return (aliases, response)
        }
        return (nil, response)
    }

    public func delete(name: String) async throws -> (CollectionAlias?, URLResponse?) {
        let (data, response) = try await apiCall.delete(endPoint: endpointPath(name))
        if let result = data {
            let alias = try decoder.decode(CollectionAlias.self, from: result)
            return (alias, response)
        }
        return (nil, response)
    }

    private func endpointPath(_ operation: String? = nil) throws -> String {
        if let operation: String = operation {
            return try "\(RESOURCEPATH)/\(operation.encodeURL())"
        } else {
            return RESOURCEPATH
        }
    }
}
