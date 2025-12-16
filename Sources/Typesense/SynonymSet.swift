import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct SynonymSet {
    var apiCall: ApiCall
    let synonymSetName: String


    init(apiCall: ApiCall, synonymSetName: String) {
        self.apiCall = apiCall
        self.synonymSetName = synonymSetName
    }

    public func items() -> SynonymSetItems {
        return SynonymSetItems(apiCall: apiCall, synonymSetName: synonymSetName)
    }

    public func item(_ name: String) -> SynonymSetItem {
        return SynonymSetItem(apiCall: apiCall, synonymSetName: synonymSetName, itemName: name)
    }


    public func retrieve() async throws -> (SynonymSetSchema?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath(synonymSetName))
        if let result = data {
            let synonym = try decoder.decode(SynonymSetSchema.self, from: result)
            return (synonym, response)
        }
        return (nil, nil)
    }

    public func delete() async throws -> (SynonymSetDeleteSchema?, URLResponse?) {
        let (data, response) = try await apiCall.delete(endPoint: endpointPath(synonymSetName))
        if let result = data {
            let synonym = try decoder.decode(SynonymSetDeleteSchema.self, from: result)
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
