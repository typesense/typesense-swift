import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct CurationSet {
    private var apiCall: ApiCall
    private var curationSetName: String


    init(apiCall: ApiCall, curationSetName: String) {
        self.apiCall = apiCall
        self.curationSetName = curationSetName
    }

    public func item(_ name: String) -> CurationSetItem {
        return CurationSetItem(apiCall: apiCall, curationSetName: curationSetName, itemName: name)
    }

    public func items() -> CurationSetItems {
        return CurationSetItems(apiCall: apiCall, curationSetName: curationSetName)
    }

    public func retrieve() async throws -> (CurationSetSchema?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath())
        if let result = data {
            let override = try decoder.decode(CurationSetSchema.self, from: result)
            return (override, response)
        }
        return (nil, response)
    }

    public func delete() async throws -> (CurationSetDeleteSchema?, URLResponse?) {
        let (data, response) = try await apiCall.delete(endPoint: endpointPath())
        if let result = data {
            let decodedData = try decoder.decode(CurationSetDeleteSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    private func endpointPath() throws -> String {
        return try "\(CurationSets.RESOURCEPATH)/\(curationSetName.encodeURL())"
    }


}
