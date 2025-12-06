import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct CurationSets {
    static let RESOURCEPATH = "curation_sets"
    private var apiCall: ApiCall


    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }

    public func upsert(_ curationSetName: String, _ params: CurationSetCreateSchema) async throws -> (CurationSetSchema?, URLResponse?) {
        let schemaData = try encoder.encode(params)
        let (data, response) = try await self.apiCall.put(endPoint: endpointPath(curationSetName), body: schemaData)

        if let result = data {
            let curationSet = try decoder.decode(CurationSetSchema.self, from: result)
            return (curationSet, response)
        }
        return (nil, response)
    }

    public func retrieve() async throws -> ([CurationSetSchema]?, URLResponse?) {
        let (data, response) = try await self.apiCall.get(endPoint: endpointPath())
        if let result = data {
            let curationSets = try decoder.decode([CurationSetSchema].self, from: result)
            return (curationSets, response)
        }
        return (nil, nil)
    }

    private func endpointPath(_ operation: String? = nil) throws -> String {
        let baseEndpoint = "\(CurationSets.RESOURCEPATH)"
        if let operation = operation {
            return try "\(baseEndpoint)/\(operation.encodeURL())"
        } else {
            return baseEndpoint
        }
    }

}
