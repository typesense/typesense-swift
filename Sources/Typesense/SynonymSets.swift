import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct SynonymSets {
    static let RESOURCE_PATH = "synonym_sets"
    var apiCall: ApiCall


    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }


    public func upsert(_ id: String, _ schema: SynonymSetCreateSchema) async throws -> (SynonymSetSchema?, URLResponse?) {
        let schemaData = try encoder.encode(schema)

        let (data, response) = try await apiCall.put(endPoint: endpointPath(id), body: schemaData)
        if let result = data {
            let synonym = try decoder.decode(SynonymSetSchema.self, from: result)
            return (synonym, response)
        }

        return (nil, nil)
    }

    public func retrieve() async throws -> ([SynonymSetSchema]?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath())
        if let result = data {
            let synonym = try decoder.decode([SynonymSetSchema].self, from: result)
            return (synonym, response)
        }
        return (nil, response)
    }

    private func endpointPath(_ operation: String? = nil) throws -> String {
        let baseEndpoint = SynonymSets.RESOURCE_PATH
        if let operation: String = operation {
            return "\(baseEndpoint)/\(try operation.encodeURL())"
        } else {
            return baseEndpoint
        }
    }
}
