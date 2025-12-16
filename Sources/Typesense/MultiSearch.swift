import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct MultiSearch {
    var apiCall: ApiCall
    let RESOURCEPATH = "multi_search"

    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }

    public func perform(searchRequests: [MultiSearchCollectionParameters], commonParameters: MultiSearchParameters) async throws -> (Data?, URLResponse?) {
        let queryParams = try createURLQuery(forSchema: commonParameters)
        let searchesData = try encoder.encode(MultiSearchSearchesParameter(searches: searchRequests))

        return try await apiCall.post(endPoint: "\(RESOURCEPATH)", body: searchesData, queryParameters: queryParams)
    }

    public func performUnion(searchRequests: [MultiSearchCollectionParameters], commonParameters: MultiSearchParameters) async throws -> (Data?, URLResponse?) {
        let queryParams = try createURLQuery(forSchema: commonParameters)
        let searchesData = try encoder.encode(MultiSearchSearchesParameter(searches: searchRequests, union: true))

        return try await apiCall.post(endPoint: "\(RESOURCEPATH)", body: searchesData, queryParameters: queryParams)
    }

    public func perform<T>(searchRequests: [MultiSearchCollectionParameters], commonParameters: MultiSearchParameters, for: T.Type) async throws -> (MultiSearchResult<T>?, URLResponse?) {
        let queryParams = try createURLQuery(forSchema: commonParameters)
        let searches = MultiSearchSearchesParameter(searches: searchRequests)

        let searchesData = try encoder.encode(searches)

        let (data, response) = try await apiCall.post(endPoint: "\(RESOURCEPATH)", body: searchesData, queryParameters: queryParams)

        if let validData = data {
            let searchRes = try decoder.decode(MultiSearchResult<T>.self, from: validData)
            return (searchRes, response)
        }

        return (nil, response)
    }

    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    public func perform<each T: Codable>(searchRequests: [MultiSearchCollectionParameters], commonParameters: MultiSearchParameters, for types: (repeat (each T).Type)
) async throws -> (MultiSearchResultPack<repeat each T>?, URLResponse?) {
        let queryParams = try createURLQuery(forSchema: commonParameters)
        let searches = MultiSearchSearchesParameter(searches: searchRequests)

        let searchesData = try encoder.encode(searches)

        let (data, response) = try await apiCall.post(endPoint: "\(RESOURCEPATH)", body: searchesData, queryParameters: queryParams)

        if let validData = data {
            let searchRes = try decoder.decode(MultiSearchResultPack<repeat each T>.self, from: validData)
            return (searchRes, response)
        }

        return (nil, response)
    }

    public func performUnion<T>(searchRequests: [MultiSearchCollectionParameters], commonParameters: MultiSearchParameters, for: T.Type) async throws -> (SearchResult<T>?, URLResponse?) {
        let queryParams = try createURLQuery(forSchema: commonParameters)
        let searches = MultiSearchSearchesParameter(searches: searchRequests, union: true)

        let searchesData = try encoder.encode(searches)

        let (data, response) = try await apiCall.post(endPoint: "\(RESOURCEPATH)", body: searchesData, queryParameters: queryParams)

        if let validData = data {
            let searchRes = try decoder.decode(SearchResult<T>.self, from: validData)
            return (searchRes, response)
        }

        return (nil, response)
    }


}
