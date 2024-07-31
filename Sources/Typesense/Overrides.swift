import Foundation
import FoundationNetworking

public struct Overrides {
    static let RESOURCEPATH = "overrides"
    private var apiCall: ApiCall
    private var collectionName: String


    init(config: Configuration, collectionName: String) {
        self.apiCall = ApiCall(config: config)
        self.collectionName = collectionName
    }

    public func upsert<T: Codable>(overrideId: String, params: SearchOverrideSchema<T>) async throws -> (SearchOverride<T>?, URLResponse?) {
        let schemaData = try encoder.encode(params)
        let (data, response) = try await self.apiCall.put(endPoint: endpointPath(overrideId), body: schemaData)

        if let result = data {
            if let error = try? decoder.decode(ApiResponse.self, from: result) {
                throw ResponseError.requestMalformed(desc: "Overrides \(error.message)")
            }
            let override = try decoder.decode(SearchOverride<T>.self, from: result)
            return (override, response)
        }

        return (nil, response)
    }

    public func retrieve<T: Codable>(metadataType: T.Type) async throws -> (SearchOverridesResponse<T>?, URLResponse?) {
        let (data, response) = try await self.apiCall.get(endPoint: endpointPath())
        if let result = data {
            let overrides = try decoder.decode(SearchOverridesResponse<T>.self, from: result)
            return (overrides, response)
        }
        return (nil, nil)
    }

    private func endpointPath(_ operation: String? = nil) -> String {
        let baseEndpoint = "\(Collections.RESOURCEPATH)/\(collectionName)/\(Overrides.RESOURCEPATH)"
        if let operation = operation {
            return "\(baseEndpoint)/\(operation)"
        } else {
            return baseEndpoint
        }
    }


}
