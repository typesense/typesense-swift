import Foundation

private let urlAllowed: CharacterSet = .alphanumerics.union(.init(charactersIn: "-._~"))

internal extension String {
    func encodeURL() throws -> String {
        let percentEncoded = self.addingPercentEncoding(withAllowedCharacters: urlAllowed)
        guard let valid = percentEncoded else{
            throw URLError.encodingError(message: "Failed to encode URL for string `\(self)`")
        }
        return valid
    }
}

extension MultiSearchSearchesParameter {
    public init(searches: [MultiSearchParameters]) {
        self.searches = searches.map { params in
            var collectionParams = MultiSearchCollectionParameters()
            collectionParams.q = params.q
            collectionParams.queryBy = params.queryBy
            collectionParams.queryByWeights = params.queryByWeights
            collectionParams.textMatchType = params.textMatchType
            collectionParams._prefix = params._prefix
            collectionParams._infix = params._infix
            collectionParams.maxExtraPrefix = params.maxExtraPrefix
            collectionParams.maxExtraSuffix = params.maxExtraSuffix
            collectionParams.filterBy = params.filterBy
            collectionParams.sortBy = params.sortBy
            collectionParams.facetBy = params.facetBy
            collectionParams.maxFacetValues = params.maxFacetValues
            collectionParams.facetQuery = params.facetQuery
            collectionParams.numTypos = params.numTypos
            collectionParams.page = params.page
            collectionParams.perPage = params.perPage
            collectionParams.limit = params.limit
            collectionParams.offset = params.offset
            collectionParams.groupBy = params.groupBy
            collectionParams.groupLimit = params.groupLimit
            collectionParams.groupMissingValues = params.groupMissingValues
            collectionParams.includeFields = params.includeFields
            collectionParams.excludeFields = params.excludeFields
            collectionParams.highlightFullFields = params.highlightFullFields
            collectionParams.highlightAffixNumTokens = params.highlightAffixNumTokens
            collectionParams.highlightStartTag = params.highlightStartTag
            collectionParams.highlightEndTag = params.highlightEndTag
            collectionParams.snippetThreshold = params.snippetThreshold
            collectionParams.dropTokensThreshold = params.dropTokensThreshold
            collectionParams.typoTokensThreshold = params.typoTokensThreshold
            collectionParams.pinnedHits = params.pinnedHits
            collectionParams.hiddenHits = params.hiddenHits
            collectionParams.overrideTags = params.overrideTags
            collectionParams.highlightFields = params.highlightFields
            collectionParams.preSegmentedQuery = params.preSegmentedQuery
            collectionParams.preset = params.preset
            collectionParams.enableOverrides = params.enableOverrides
            collectionParams.prioritizeExactMatch = params.prioritizeExactMatch
            collectionParams.prioritizeTokenPosition = params.prioritizeTokenPosition
            collectionParams.prioritizeNumMatchingFields = params.prioritizeNumMatchingFields
            collectionParams.enableTyposForNumericalTokens = params.enableTyposForNumericalTokens
            collectionParams.exhaustiveSearch = params.exhaustiveSearch
            collectionParams.searchCutoffMs = params.searchCutoffMs
            collectionParams.useCache = params.useCache
            collectionParams.cacheTtl = params.cacheTtl
            collectionParams.minLen1typo = params.minLen1typo
            collectionParams.minLen2typo = params.minLen2typo
            collectionParams.vectorQuery = params.vectorQuery
            collectionParams.remoteEmbeddingTimeoutMs = params.remoteEmbeddingTimeoutMs
            collectionParams.remoteEmbeddingNumTries = params.remoteEmbeddingNumTries
            collectionParams.facetStrategy = params.facetStrategy
            collectionParams.stopwords = params.stopwords
            collectionParams.facetReturnParent = params.facetReturnParent
            collectionParams.voiceQuery = params.voiceQuery
            collectionParams.rerankHybridMatches = params.rerankHybridMatches
            collectionParams.xTypesenseApiKey = params.xTypesenseApiKey
            return collectionParams
        }
    }
}
