import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct SynonymSetItem {
    var apiCall: ApiCall
    let synonymSetName: String
    let itemName: String

    init(apiCall: ApiCall, synonymSetName: String, itemName: String) {
        self.apiCall = apiCall
        self.synonymSetName = synonymSetName
        self.itemName = itemName
    }

    public func retrieve() async throws -> (SynonymItemSchema?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath(itemName))
        if let result = data {
            let synonym = try decoder.decode(SynonymItemSchema.self, from: result)
            return (synonym, response)
        }
        return (nil, nil)
    }

    public func delete() async throws -> (SynonymItemDeleteSchema?, URLResponse?) {
        let (data, response) = try await apiCall.delete(endPoint: endpointPath(itemName))
        if let result = data {
            let synonym = try decoder.decode(SynonymItemDeleteSchema.self, from: result)
            return (synonym, response)
        }
        return (nil, response)
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
