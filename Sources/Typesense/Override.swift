import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct Override {
    private var apiCall: ApiCall
    private var collectionName: String
    private var overrideId: String


    init(apiCall: ApiCall, collectionName: String, overrideId: String) {
        self.apiCall = apiCall
        self.collectionName = collectionName
        self.overrideId = overrideId
    }

    // public func retrieve<T: Codable>(metadataType: T.Type) async throws -> (SearchOverride<T>?, URLResponse?) {
    //     let (data, response) = try await apiCall.get(endPoint: endpointPath())
    //     if let result = data {
    //         let override = try decoder.decode(SearchOverride<T>.self, from: result)
    //         return (override, response)
    //     }

    //     return (nil, response)
    // }

    // public func delete() async throws -> (SearchOverrideDeleteResponse?, URLResponse?) {
    //     let (data, response) = try await apiCall.delete(endPoint: endpointPath())
    //     if let result = data {
    //         let decodedData = try decoder.decode(SearchOverrideDeleteResponse.self, from: result)
    //         return (decodedData, response)
    //     }
    //     return (nil, response)
    // }

    private func endpointPath() throws -> String {
        return try "\(Collections.RESOURCEPATH)/\(collectionName.encodeURL())/\(Overrides.RESOURCEPATH)/\(overrideId.encodeURL())"
    }


}
