import Foundation

public struct Analytics {
    static let resourcePath: String = "/analytics"

    private var analyticsRules: AnalyticsRules
    var apiCall: ApiCall

    init(apiCall: ApiCall) {
        self.apiCall = apiCall
        self.analyticsRules = AnalyticsRules(apiCall: apiCall)
    }

    public func rule(id: String) -> AnalyticsRule {
        return AnalyticsRule(name: id, apiCall: self.apiCall)
    }

    public func rules() -> AnalyticsRules {
        return AnalyticsRules(apiCall: self.apiCall)
    }
}



