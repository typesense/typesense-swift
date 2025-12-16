import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct AnalyticsRuleAPI {
    var name: String
    private var apiCall: ApiCall
    init(name: String, apiCall: ApiCall) {
        self.name = name
        self.apiCall = apiCall
    }

    public func retrieve() async throws -> (AnalyticsRule?, URLResponse?) {
        let (data, response) = try await self.apiCall.get(endPoint: endpointPath())
        if let result = data {
            let fetchedRule = try decoder.decode(AnalyticsRule.self, from: result)
            return (fetchedRule, response)
        }
        return (nil, response)
    }

    public func delete() async throws -> (AnalyticsRule?, URLResponse?) {
        let (data, response) = try await self.apiCall.delete(endPoint: endpointPath())
        if let result = data {
            let deletedRule = try decoder.decode(AnalyticsRule.self, from: result)
            return (deletedRule, response)
        }
        return (nil, response)
    }

    private func endpointPath() throws -> String {
        return try "\(AnalyticsRules.resourcePath)/\(name.encodeURL())"
    }
}
