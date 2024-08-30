import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct ConversationModels {
    static let RESOURCE_PATH = "models"
    private var apiCall: ApiCall


    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }

    public func create(params: ConversationModelCreateSchema) async throws -> (ConversationModelSchema?, URLResponse?) {
        let schemaData = try encoder.encode(params)
        let (data, response) = try await self.apiCall.post(endPoint: endpointPath(), body: schemaData)
        if let result = data {
            let decodedData = try decoder.decode(ConversationModelSchema.self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    public func retrieve() async throws -> ([ConversationModelSchema]?, URLResponse?) {
        let (data, response) = try await self.apiCall.get(endPoint: endpointPath())
        if let result = data {
            let decodedData = try decoder.decode([ConversationModelSchema].self, from: result)
            return (decodedData, response)
        }
        return (nil, response)
    }

    private func endpointPath() throws -> String {
        return "\(Conversations.RESOURCE_PATH)/\(ConversationModels.RESOURCE_PATH)"
    }


}
