import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct Presets {
    static let RESOURCEPATH = "presets"
    private var apiCall: ApiCall


    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }

    public func upsert(presetName: String, params: PresetUpsertSchema) async throws -> (PresetSchema?, URLResponse?) {
        let schemaData = try encoder.encode(params)
        let (data, response) = try await self.apiCall.put(endPoint: endpointPath(presetName), body: schemaData)
        if let result = data {
            let decodedData = try decoder.decode(PresetSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    public func retrieve() async throws -> (PresetsRetrieveSchema?, URLResponse?) {
        let (data, response) = try await self.apiCall.get(endPoint: endpointPath())
        if let result = data {
            let decodedData = try decoder.decode(PresetsRetrieveSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    private func endpointPath(_ operation: String? = nil) throws -> String {
        let baseEndpoint = "\(Presets.RESOURCEPATH)"
        if let operation = operation {
            return try "\(baseEndpoint)/\(operation.encodeURL())"
        } else {
            return baseEndpoint
        }
    }


}
