import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct ConversationModel {
    private var apiCall: ApiCall
    var modelId: String

    init(apiCall: ApiCall, modelId: String) {
        self.apiCall = apiCall
        self.modelId = modelId
    }

    public func update(params: ConversationModelUpdateSchema) async throws -> (ConversationModelSchema?, URLResponse?) {
        let schemaData = try encoder.encode(params)
        let (data, response) = try await self.apiCall.put(endPoint: endpointPath(), body: schemaData)
        if let result = data {
            let decodedData = try decoder.decode(ConversationModelSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    public func retrieve() async throws -> (ConversationModelSchema?, URLResponse?) {
        let (data, response) = try await self.apiCall.get(endPoint: endpointPath())
        if let result = data {
            let decodedData = try decoder.decode(ConversationModelSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    public func delete() async throws -> (ConversationModelSchema?, URLResponse?) {
        let (data, response) = try await self.apiCall.delete(endPoint: endpointPath())
        if let result = data {
            let decodedData = try decoder.decode(ConversationModelSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    private func endpointPath() throws -> String {
        return try "\(Conversations.RESOURCE_PATH)/\(ConversationModels.RESOURCE_PATH)/\(modelId.encodeURL())"
    }


}
