import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct Overrides {
    static let RESOURCEPATH = "overrides"
    private var apiCall: ApiCall
    private var collectionName: String


    init(apiCall: ApiCall, collectionName: String) {
        self.apiCall = apiCall
        self.collectionName = collectionName
    }

    // public func upsert<T: Codable>(overrideId: String, params: SearchOverrideSchema<T>) async throws -> (SearchOverride<T>?, URLResponse?) {
    //     let schemaData = try encoder.encode(params)
    //     let (data, response) = try await self.apiCall.put(endPoint: endpointPath(overrideId), body: schemaData)

    //     if let result = data {
    //         let override = try decoder.decode(SearchOverride<T>.self, from: result)
    //         return (override, response)
    //     }

    //     return (nil, response)
    // }

    // public func retrieve<T: Codable>(metadataType: T.Type) async throws -> (SearchOverridesResponse<T>?, URLResponse?) {
    //     let (data, response) = try await self.apiCall.get(endPoint: endpointPath())
    //     if let result = data {
    //         let overrides = try decoder.decode(SearchOverridesResponse<T>.self, from: result)
    //         return (overrides, response)
    //     }
    //     return (nil, nil)
    // }

    private func endpointPath(_ operation: String? = nil) throws -> String {
        let baseEndpoint = try "\(Collections.RESOURCEPATH)/\(collectionName.encodeURL())/\(Overrides.RESOURCEPATH)"
        if let operation = operation {
            return try "\(baseEndpoint)/\(operation.encodeURL())"
        } else {
            return baseEndpoint
        }
    }


}
