import Foundation

public struct Client {

    var configuration: Configuration
    var apiCall: ApiCall
    public var collections: Collections

    public init(config: Configuration) {
        self.configuration = config
        self.apiCall = ApiCall(config: config)
        self.collections = Collections(config: config)
    }

    public func collection(name: String) -> Collection {
        return Collection(config: self.configuration, collectionName: name)
    }

    public func keys() -> ApiKeys {
        return ApiKeys(config: self.configuration)
    }

    public func aliases() -> Alias {
        return Alias(config: self.configuration)
    }

    public func operations() -> Operations {
        return Operations(config: self.configuration)
    }

    public func multiSearch() -> MultiSearch {
        return MultiSearch(config: self.configuration)
    }

    public func analytics() -> Analytics {
        return Analytics(config: self.configuration)
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
