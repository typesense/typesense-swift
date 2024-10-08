import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif


public struct AnalyticsRules {
    private var apiCall: ApiCall
    static var resourcePath: String = "\(Analytics.resourcePath)/rules"

    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }

    public func upsert(params: AnalyticsRuleSchema) async throws -> (AnalyticsRuleSchema?, URLResponse?) {
        let ruleData = try encoder.encode(params)
        let (data, response) = try await self.apiCall.put(endPoint: endpointPath(params.name), body: ruleData)
        if let result = data {
            let ruleResult = try decoder.decode(AnalyticsRuleSchema.self, from: result)
            return (ruleResult, response)
        }

        return (nil, response)
    }

    public func retrieveAll() async throws -> (AnalyticsRulesRetrieveSchema?, URLResponse?) {
        let (data, response) = try await self.apiCall.get(endPoint: endpointPath())
        if let result = data {
            let rules = try decoder.decode(AnalyticsRulesRetrieveSchema.self, from: result)
            return (rules, response)
        }

        return (nil, response)
    }

    private func endpointPath(_ operation: String? = nil) throws -> String {
        if let operation = operation {
            return try "\(AnalyticsRules.resourcePath)/\(operation.encodeURL())"
        } else {
            return AnalyticsRules.resourcePath
        }
    }
}
