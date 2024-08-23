import Foundation



public struct AnalyticsRuleSchema: Codable {

    public enum RuleType: String, Codable {
        case popularQueries = "popular_queries"
        case nohitsQueries = "nohits_queries"
        case counter = "counter"
    }
    public var name: String
    public var type: RuleType
    public var params: AnalyticsRuleParameters

    public init(name: String, type: RuleType, params: AnalyticsRuleParameters) {
        self.name = name
        self.type = type
        self.params = params
    }


}
