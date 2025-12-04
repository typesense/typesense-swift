import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public enum AnalyticsRuleCreateManyResponseItem: Codable {
    case success(AnalyticsRule)
    case error(CreateAnalyticsRuleError)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .success(let value):
            try container.encode(value)
        case .error(let value):
            try container.encode(value)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(AnalyticsRule.self) {
            self = .success(value)
        } else if let value = try? container.decode(CreateAnalyticsRuleError.self) {
            self = .error(value)
        } else {
            throw DecodingError.typeMismatch(Self.Type.self, .init(codingPath: decoder.codingPath, debugDescription: "Unable to decode instance of AnalyticsRuleCreateManyResponseItem"))
        }
    }
}

public struct CreateAnalyticsRuleError: Codable {

    public var error: String?

    public init(error: String? = nil) {
        self.error = error
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case error
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(error, forKey: .error)
    }
}
