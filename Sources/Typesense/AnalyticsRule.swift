import Foundation

public struct AnalyticsRule {
    var name: String
    private var apiCall: ApiCall
    init(name: String, apiCall: ApiCall) {
        self.name = name
        self.apiCall = apiCall
    }
    
    public func retrieve() async throws -> (AnalyticsRuleSchema?, URLResponse?) {
        let (data, response) = try await self.apiCall.get(endPoint: endpointPath())
        if let result = data {
            if let notFound = try? decoder.decode(ApiResponse.self, from: result) {
                throw ResponseError.analyticsRuleDoesNotExist(desc: notFound.message)
            }
            let fetchedRule = try decoder.decode(AnalyticsRuleSchema.self, from: result)
            return (fetchedRule, response)
        }
        return (nil, response)
    }
    
    public func delete() async throws -> (AnalyticsRuleSchema?, URLResponse?) {
        let (data, response) = try await self.apiCall.delete(endPoint: endpointPath())
        if let result = data {
            if let notFound = try? decoder.decode(ApiResponse.self, from: result) {
                throw ResponseError.analyticsRuleDoesNotExist(desc: notFound.message)
            }
            let deletedRule = try decoder.decode(AnalyticsRuleSchema.self, from: result)
            return (deletedRule, response)
        }
        return (nil, response)
    }
    
    private func endpointPath() -> String {
        return "\(AnalyticsRules.resourcePath)/\(name)"
    }
}
