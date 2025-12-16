import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct SynonymSetItems {
    var apiCall: ApiCall
    let synonymSetName: String


    init(apiCall: ApiCall, synonymSetName: String) {
        self.apiCall = apiCall
        self.synonymSetName = synonymSetName
    }

    public func retrieve() async throws -> ([SynonymItemSchema]?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath())
        if let result = data {
            let synonym = try decoder.decode([SynonymItemSchema].self, from: result)
            return (synonym, response)
        }
        return (nil, response)
    }

    public func upsert(_ id: String, _ schema: SynonymItemUpsertSchema) async throws -> (SynonymItemSchema?, URLResponse?) {
        let schemaData = try encoder.encode(schema)

        let (data, response) = try await apiCall.put(endPoint: endpointPath(id), body: schemaData)
        if let result = data {
            let synonym = try decoder.decode(SynonymItemSchema.self, from: result)
            return (synonym, response)
        }

        return (nil, nil)
    }

    private func endpointPath(_ operation: String? = nil) throws -> String {
        let baseEndpoint = try "\(SynonymSets.RESOURCE_PATH)/\(synonymSetName.encodeURL())/items"
        if let operation: String = operation {
            return "\(baseEndpoint)/\(try operation.encodeURL())"
        } else {
            return baseEndpoint
        }
    }
}
