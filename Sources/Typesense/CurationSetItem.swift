import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct CurationSetItem {
    private var apiCall: ApiCall
    private var curationSetName: String
    private var itemName: String


    init(apiCall: ApiCall, curationSetName: String, itemName: String) {
        self.apiCall = apiCall
        self.curationSetName = curationSetName
        self.itemName = itemName
    }

    public func retrieve() async throws -> (CurationItemSchema?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath())
        if let result = data {
            let schema = try decoder.decode(CurationItemSchema.self, from: result)
            return (schema, response)
        }
        return (nil, response)
    }

    public func delete() async throws -> (CurationItemDeleteSchema?, URLResponse?) {
        let (data, response) = try await apiCall.delete(endPoint: endpointPath())
        if let result = data {
            let decodedData = try decoder.decode(CurationItemDeleteSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    private func endpointPath() throws -> String {
        return try "\(CurationSets.RESOURCEPATH)/\(curationSetName.encodeURL())/items/\(itemName.encodeURL())"
    }


}
