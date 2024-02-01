import Foundation

public struct AnalyticsRules {
    private var apiCall: ApiCall
    
    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }
    
    func create(name: String, params: AnalyticsRuleSchema) async throws -> (AnalyticsRuleSchema?, URLResponse?) {
        let ruleData = try encoder.encode(params)
        let (data, response) = try await self.apiCall.put(endPoint: "\(Analytics.resourcePath)/\(name)", body: ruleData)
        if let result = data {
            let ruleResult = try decoder.decode(AnalyticsRuleSchema.self, from: result)
            return (ruleResult, response)
        }
    
        return (nil, response)
    }
    
    func retrieveAll() async throws -> (AnalyticsRulesRetrieveSchema?, URLResponse?) {
        let (data, response) = try await self.apiCall.get(endPoint: "\(Analytics.resourcePath)")
        if let result = data {
            let rules = try decoder.decode(AnalyticsRulesRetrieveSchema.self, from: result)
            return (rules, response)
        }
        
        return (nil, response)
    }
}
