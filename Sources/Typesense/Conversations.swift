import Foundation

public struct Conversations {
    static let RESOURCE_PATH = "conversations"
    private var apiCall: ApiCall


    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }

    public func models() -> ConversationModels {
        return ConversationModels(apiCall: apiCall)
    }

    public func model(modelId: String) -> ConversationModel {
        return ConversationModel(apiCall: apiCall, modelId: modelId)
    }

}
