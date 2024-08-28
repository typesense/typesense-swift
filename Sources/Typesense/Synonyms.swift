import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct Synonyms {
    var apiCall: ApiCall
    var collectionName: String

    init(apiCall: ApiCall, collectionName: String) {
        self.apiCall = apiCall
        self.collectionName = collectionName
    }

    public func upsert(id: String, _ searchSynonym: SearchSynonymSchema) async throws -> (SearchSynonym?, URLResponse?) {
        var schemaData: Data? = nil
        schemaData = try encoder.encode(searchSynonym)

        if let validSchema = schemaData {
            let (data, response) = try await apiCall.put(endPoint: endpointPath(id), body: validSchema)
            if let result = data {
                let synonym = try decoder.decode(SearchSynonym.self, from: result)
                return (synonym, response)
            }

        }
        return (nil, nil)
    }

    public func retrieve(id: String) async throws -> (SearchSynonym?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath(id))
        if let result = data {
            let synonym = try decoder.decode(SearchSynonym.self, from: result)
            return (synonym, response)
        }
        return (nil, nil)
    }

    public func retrieve() async throws -> (SearchSynonymsResponse?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath())
        if let result = data {
            let synonym = try decoder.decode(SearchSynonymsResponse.self, from: result)
            return (synonym, response)
        }
        return (nil, nil)
    }

    public func delete(id: String) async throws -> (Data?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath())
        return (data, response)
    }

    private func endpointPath(_ operation: String? = nil) throws -> String {
        let baseEndpoint = try "\(Collections.RESOURCEPATH)/\(collectionName.encodeURL())/synonyms"
        if let operation: String = operation {
            return "\(baseEndpoint)/\(try operation.encodeURL())"
        } else {
            return baseEndpoint
        }
    }
}
