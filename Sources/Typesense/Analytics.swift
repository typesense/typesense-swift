import Foundation

let RESOURCEPATH = "/analytics"

public struct Analytics {
    static var resourcePath: String {
        return RESOURCEPATH
    }
    
    private var analyticsRules: AnalyticsRules
    var apiCall: ApiCall

    init(config: Configuration) {
        self.apiCall = ApiCall(config: config)
        self.analyticsRules = AnalyticsRules(apiCall: apiCall)
    }
    
    func rule(id: String) -> AnalyticsRule {
        return AnalyticsRule(name: id, apiCall: self.apiCall)
    }
    
    func rules() -> AnalyticsRules {
        return AnalyticsRules(apiCall: self.apiCall)
    }
}



