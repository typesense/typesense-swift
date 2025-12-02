import Foundation

public struct Client {

    var configuration: Configuration
    var apiCall: ApiCall

    public init(config: Configuration) {
        self.configuration = config
        self.apiCall = ApiCall(config: config)
    }
    
    public func collections() -> Collections {
        return Collections(apiCall: apiCall)
    }

    public func collection(name: String) -> Collection {
        return Collection(apiCall: apiCall, collectionName: name)
    }

    public func conversations() -> Conversations {
        return Conversations(apiCall: apiCall)
    }

    public func keys() -> ApiKeys {
        return ApiKeys(apiCall: apiCall)
    }

    public func aliases() -> Alias {
        return Alias(apiCall: apiCall)
    }

    public func operations() -> Operations {
        return Operations(apiCall: apiCall)
    }

    public func multiSearch() -> MultiSearch {
        return MultiSearch(apiCall: apiCall)
    }

    public func analytics() -> Analytics {
        return Analytics(apiCall: apiCall)
    }

    public func presets() -> Presets {
        return Presets(apiCall: apiCall)
    }

    public func preset(_ presetName: String) -> Preset {
        return Preset(apiCall: apiCall, presetName: presetName)
    }

    public func stopwords() -> Stopwords {
        return Stopwords(apiCall: apiCall)
    }

    public func stopword(_ stopwordsSetId: String) -> Stopword {
        return Stopword(apiCall: apiCall, stopwordsSetId: stopwordsSetId)
    }
}
