import Foundation
import FoundationNetworking

public let encoder = JSONEncoder()
public let decoder = JSONDecoder()

public enum StringQuantum: Codable {

    public var arrStr : [String]? {
        guard case .arrOfStrings(let arrOfStrings) = self else { return nil }
        return arrOfStrings
    }

    public var arrArrStr : [[String]]? {
        guard case .arrOfArrOfStrings(let arrOfArrOfStrings) = self else { return nil }
        return arrOfArrOfStrings
    }

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

@available(iOS, deprecated: 15.0, message: "Use the built-in API instead")
extension URLSession {
    func data(for req: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: req) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError.invalidURL
                    return continuation.resume(throwing: error)
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }
}
