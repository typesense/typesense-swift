import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct Stopword {
    private var apiCall: ApiCall
    private var stopwordsSetId: String


    init(apiCall: ApiCall, stopwordsSetId: String) {
        self.apiCall = apiCall
        self.stopwordsSetId = stopwordsSetId
    }

    public func retrieve() async throws -> (StopwordsSetSchema?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath())
        if let result = data {
            let decodedData = try decoder.decode(StopwordsSetRetrieveSchema.self, from: result)
            return (decodedData.stopwords, response)
        }
        return (nil, response)
    }

    public func delete() async throws -> (StopwordsSetDeleteSchema?, URLResponse?) {
        let (data, response) = try await apiCall.delete(endPoint: endpointPath())
        if let result = data {
            let decodedData = try decoder.decode(StopwordsSetDeleteSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    private func endpointPath() -> String {
        return "\(Stopwords.RESOURCEPATH)/\(stopwordsSetId)"
    }


}
