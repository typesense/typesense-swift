import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif


public struct Operations {
    var apiCall: ApiCall
    var RESOURCEPATH = "operations"

    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }

    public func getHealth() async throws -> (HealthStatus?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: "health")
        if let result = data {
            let health = try decoder.decode(HealthStatus.self, from: result)
            return (health, response)
        }
        return (nil, nil)
    }

    public func getStats() async throws -> (Data?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: "stats.json")
        return (data, response)
    }

    public func getMetrics() async throws -> (Data?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: "metrics.json")
        return (data, response)
    }

    public func getDebug() async throws -> (DebugRetrieveSchema?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: "debug")
        if let result = data {
            let decodedData = try decoder.decode(DebugRetrieveSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    public func vote() async throws -> (SuccessStatus?, URLResponse?) {
        let (data, response) = try await apiCall.post(endPoint: "\(RESOURCEPATH)/vote", body: Data())
        if let result = data {
            let success = try decoder.decode(SuccessStatus.self, from: result)
            return (success, response)
        }
        return (nil, nil)
    }

    public func snapshot(path: String? = "/tmp/typesense-data-snapshot") async throws -> (SuccessStatus?, URLResponse?) {
        let snapshotQueryParam = URLQueryItem(name: "snapshot_path", value: path)
        let (data, response) = try await apiCall.post(endPoint: "\(RESOURCEPATH)/snapshot", body: Data(), queryParameters: [snapshotQueryParam])
        if let result = data {
            let success = try decoder.decode(SuccessStatus.self, from: result)
            return (success, response)
        }
        return (nil, nil)
    }

    public func toggleSlowRequestLog(seconds: Float) async throws -> (SuccessStatus?, URLResponse?) {
        let durationInMs = seconds * 1000
        let slowReq = SlowRequest(durationInMs)
        let slowReqData = try encoder.encode(slowReq)
        let (data, response) = try await apiCall.post(endPoint: "/config", body: slowReqData)
        if let result = data {
            let success = try decoder.decode(SuccessStatus.self, from: result)
            return (success, response)
        }
        return (nil, nil)
    }

}
