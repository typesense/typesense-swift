import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct AnalyticsEventsAPI {
    static var resourcePath: String = "\(Analytics.resourcePath)/events"
    var apiCall: ApiCall

    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }

    public func create(_ params: AnalyticsEvent) async throws -> (AnalyticsEventCreateResponse?, URLResponse?) {
        let json = try encoder.encode(params)
        let (data, response) = try await self.apiCall.post(endPoint: AnalyticsEventsAPI.resourcePath, body: json)
        if let result = data {
            let validData = try decoder.decode(AnalyticsEventCreateResponse.self, from: result)
            return (validData, response)
        }
        return (nil, response)
    }
}
