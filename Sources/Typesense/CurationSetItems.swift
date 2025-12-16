import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct CurationSetItems {
    private var apiCall: ApiCall
    private var curationSetName: String


    init(apiCall: ApiCall, curationSetName: String) {
        self.apiCall = apiCall
        self.curationSetName = curationSetName
    }

    public func retrieve() async throws -> ([CurationItemSchema]?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath())
        if let result = data {
            let schema = try decoder.decode([CurationItemSchema].self, from: result)
            return (schema, response)
        }
        return (nil, response)
    }

    public func upsert(_ itemName: String, _ schema: CurationItemCreateSchema) async throws -> (CurationItemSchema?, URLResponse?) {
        let schemaData = try encoder.encode(schema)
        let (data, response) = try await apiCall.put(endPoint: endpointPath(itemName), body: schemaData)

        if let result = data {
            let decodedData = try decoder.decode(CurationItemSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    private func endpointPath(_ operation: String? = nil) throws -> String {
        let baseEndpoint = try "\(CurationSets.RESOURCEPATH)/\(curationSetName.encodeURL())/items"
        if let operation = operation {
            return try "\(baseEndpoint)/\(operation.encodeURL())"
        } else {
            return baseEndpoint
        }
    }


}
