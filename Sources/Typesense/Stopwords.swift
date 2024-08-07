import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct Stopwords {
    static let RESOURCEPATH = "stopwords"
    private var apiCall: ApiCall


    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }

    public func upsert(stopwordsSetId: String, params: StopwordsSetUpsertSchema) async throws -> (StopwordsSetSchema?, URLResponse?) {
        let schemaData = try encoder.encode(params)
        let (data, response) = try await self.apiCall.put(endPoint: endpointPath(stopwordsSetId), body: schemaData)
        if let result = data {
            let decodedData = try decoder.decode(StopwordsSetSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    public func retrieve() async throws -> ([StopwordsSetSchema]?, URLResponse?) {
        let (data, response) = try await self.apiCall.get(endPoint: endpointPath())
        if let result = data {
            let decodedData = try decoder.decode(StopwordsSetsRetrieveAllSchema.self, from: result)
            return (decodedData.stopwords, response)
        }
        return (nil, response)
    }

    private func endpointPath(_ operation: String? = nil) -> String {
        let baseEndpoint = "\(Stopwords.RESOURCEPATH)"
        if let operation = operation {
            return "\(baseEndpoint)/\(operation)"
        } else {
            return baseEndpoint
        }
    }


}
