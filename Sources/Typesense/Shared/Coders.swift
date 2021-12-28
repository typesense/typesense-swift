import Foundation

public let encoder = JSONEncoder()
public let decoder = JSONDecoder()

public enum StringQuantum: Codable {
    
    case arrOfStrings([String]), arrOfArrOfStrings([[String]])
    
    public init(from decoder: Decoder) throws {
        if let arrS = try? decoder.singleValueContainer().decode([String].self) {
            self = .arrOfStrings(arrS)
            return
        }
        
        if let arrArrS = try? decoder.singleValueContainer().decode([[String]].self) {
            self = .arrOfArrOfStrings(arrArrS)
            return
        }
        
        throw QuantumError.missingValue
    }
    
    public enum QuantumError:Error {
        case missingValue
    }
}

public enum ActionModes: String {
    case create = "create"
    case upsert = "upsert"
    case update = "update"
}

public struct SlowRequest: Codable {
    public var logSlowRequestsTimeMs: Float?

    public init(_ timeInMS: Float? = nil) {
        self.logSlowRequestsTimeMs = timeInMS
    }
    
    public enum CodingKeys: String, CodingKey {
        case logSlowRequestsTimeMs = "log-slow-requests-time-ms"
    }
}
