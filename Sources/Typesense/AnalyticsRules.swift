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

    public func update(_ params: AnalyticsRuleUpdate) async throws -> (AnalyticsRule?, URLResponse?) {
        let ruleData = try encoder.encode(params)
        let (data, response) = try await self.apiCall.put(endPoint: endpointPath(params.name), body: ruleData)
        if let result = data {
            let ruleResult = try decoder.decode(AnalyticsRule.self, from: result)
            return (ruleResult, response)
        }

        return (nil, response)
    }

    public func create(_ params: AnalyticsRuleCreate) async throws -> (AnalyticsRule?, URLResponse?) {
        let ruleData = try encoder.encode(params)
        let (data, response) = try await self.apiCall.put(endPoint: endpointPath(), body: ruleData)
        if let result = data {
            let ruleResult = try decoder.decode(AnalyticsRule.self, from: result)
            return (ruleResult, response)
        }

        return (nil, response)
    }

    public func createMany(_ params: [AnalyticsRuleCreate]) async throws -> ([AnalyticsRule]?, URLResponse?) {
        let ruleData = try encoder.encode(params)
        let (data, response) = try await self.apiCall.put(endPoint: endpointPath(), body: ruleData)
        if let result = data {
            let ruleResult = try decoder.decode([AnalyticsRule].self, from: result)
            return (ruleResult, response)
        }

        return (nil, response)
    }

    public func retrieveAll(ruleTag: String? = nil) async throws -> ([AnalyticsRule]?, URLResponse?) {
        var urlParams: [URLQueryItem] = []

        if let rule_tag = ruleTag{
            urlParams.append(URLQueryItem(name: "rule_tag", value: rule_tag))
        }

        let (data, response) = try await self.apiCall.get(endPoint: endpointPath(), queryParameters: urlParams)
        if let result = data {
            let rules = try decoder.decode([AnalyticsRule].self, from: result)
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
