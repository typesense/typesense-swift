import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct Preset {
    private var apiCall: ApiCall
    private var presetName: String


    init(apiCall: ApiCall, presetName: String) {
        self.apiCall = apiCall
        self.presetName = presetName
    }

    public func retrieve() async throws -> (PresetSchema?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: endpointPath())
        if let result = data {
            let preset = try decoder.decode(PresetSchema.self, from: result)
            return (preset, response)
        }
        return (nil, response)
    }

    public func delete() async throws -> (PresetDeleteSchema?, URLResponse?) {
        let (data, response) = try await apiCall.delete(endPoint: endpointPath())
        if let result = data {
            let decodedData = try decoder.decode(PresetDeleteSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    private func endpointPath() -> String {
        return "\(Presets.RESOURCEPATH)/\(presetName)"
    }


}
