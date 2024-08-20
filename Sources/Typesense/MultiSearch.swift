import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct MultiSearch {
    var apiCall: ApiCall
    let RESOURCEPATH = "multi_search"

    init(apiCall: ApiCall) {
        self.apiCall = apiCall
    }

    public func perform<T>(searchRequests: [MultiSearchCollectionParameters], commonParameters: MultiSearchParameters, for: T.Type) async throws -> (MultiSearchResult<T>?, URLResponse?) {
        var searchQueryParams: [URLQueryItem] = []

        if let query = commonParameters.q {
            searchQueryParams.append(URLQueryItem(name: "q", value: query))
        }

        if let queryBy = commonParameters.queryBy {
            searchQueryParams.append(URLQueryItem(name: "query_by", value: queryBy))
        }

        if let queryByWeights = commonParameters.queryByWeights {
            searchQueryParams.append(URLQueryItem(name: "query_by_weights", value: queryByWeights))
        }

        if let textMatchType = commonParameters.textMatchType {
            searchQueryParams.append(URLQueryItem(name: "text_match_type", value: textMatchType))
        }

        if let _prefix = commonParameters._prefix {
            searchQueryParams.append(URLQueryItem(name: "prefix", value: _prefix))
        }

        if let _infix = commonParameters._infix {
            searchQueryParams.append(URLQueryItem(name: "infix", value: _infix))
        }

        if let maxExtraPrefix = commonParameters.maxExtraPrefix {
            searchQueryParams.append(URLQueryItem(name: "max_extra_prefix", value: String(maxExtraPrefix)))
        }

        if let maxExtraSuffix = commonParameters.maxExtraSuffix {
            searchQueryParams.append(URLQueryItem(name: "max_extra_suffix", value: String(maxExtraSuffix)))
        }

        if let filterBy = commonParameters.filterBy {
            searchQueryParams.append(URLQueryItem(name: "filter_by", value: filterBy))
        }

        if let sortBy = commonParameters.sortBy {
            searchQueryParams.append(URLQueryItem(name: "sort_by", value: sortBy))
        }

        if let facetBy = commonParameters.facetBy {
            searchQueryParams.append(URLQueryItem(name: "facet_by", value: facetBy))
        }

        if let maxFacetValues = commonParameters.maxFacetValues {
            searchQueryParams.append(URLQueryItem(name: "max_facet_values", value: String(maxFacetValues)))
        }

        if let facetQuery = commonParameters.facetQuery {
            searchQueryParams.append(URLQueryItem(name: "facet_query", value: facetQuery))
        }

        if let numTypos = commonParameters.numTypos {
            searchQueryParams.append(URLQueryItem(name: "num_typos", value: String(numTypos)))
        }

        if let page = commonParameters.page {
            searchQueryParams.append(URLQueryItem(name: "page", value: String(page)))
        }

        if let perPage = commonParameters.perPage {
            searchQueryParams.append(URLQueryItem(name: "per_page", value: String(perPage)))
        }

        if let limit = commonParameters.limit {
            searchQueryParams.append(URLQueryItem(name: "limit", value: String(limit)))
        }

        if let offset = commonParameters.offset {
            searchQueryParams.append(URLQueryItem(name: "offset", value: String(offset)))
        }

        if let groupBy = commonParameters.groupBy {
            searchQueryParams.append(URLQueryItem(name: "group_by", value: groupBy))
        }

        if let groupLimit = commonParameters.groupLimit {
            searchQueryParams.append(URLQueryItem(name: "group_limit", value: String(groupLimit)))
        }

        if let groupMissingValues = commonParameters.groupMissingValues {
            searchQueryParams.append(URLQueryItem(name: "group_missing_values", value: String(groupMissingValues)))
        }

        if let includeFields = commonParameters.includeFields {
            searchQueryParams.append(URLQueryItem(name: "include_fields", value: includeFields))
        }

        if let excludeFields = commonParameters.excludeFields {
            searchQueryParams.append(URLQueryItem(name: "exclude_fields", value: excludeFields))
        }

        if let highlightFullFields = commonParameters.highlightFullFields {
            searchQueryParams.append(URLQueryItem(name: "highlight_full_fields", value: highlightFullFields))
        }

        if let highlightAffixNumTokens = commonParameters.highlightAffixNumTokens {
            searchQueryParams.append(URLQueryItem(name: "highlight_affix_num_tokens", value: String(highlightAffixNumTokens)))
        }

        if let highlightStartTag = commonParameters.highlightStartTag {
            searchQueryParams.append(URLQueryItem(name: "highlight_start_tag", value: highlightStartTag))
        }

        if let highlightEndTag = commonParameters.highlightEndTag {
            searchQueryParams.append(URLQueryItem(name: "highlight_end_tag", value: highlightEndTag))
        }

        if let snippetThreshold = commonParameters.snippetThreshold {
            searchQueryParams.append(URLQueryItem(name: "snippet_threshold", value: String(snippetThreshold)))
        }

        if let dropTokensThreshold = commonParameters.dropTokensThreshold {
            searchQueryParams.append(URLQueryItem(name: "drop_tokens_threshold", value: String(dropTokensThreshold)))
        }

        if let typoTokensThreshold = commonParameters.typoTokensThreshold {
            searchQueryParams.append(URLQueryItem(name: "typo_tokens_threshold", value: String(typoTokensThreshold)))
        }

        if let pinnedHits = commonParameters.pinnedHits {
            searchQueryParams.append(URLQueryItem(name: "pinned_hits", value: pinnedHits))
        }

        if let hiddenHits = commonParameters.hiddenHits {
            searchQueryParams.append(URLQueryItem(name: "hidden_hits", value: hiddenHits))
        }

        if let overrideTags = commonParameters.overrideTags {
            searchQueryParams.append(URLQueryItem(name: "override_tags", value: overrideTags))
        }

        if let highlightFields = commonParameters.highlightFields {
            searchQueryParams.append(URLQueryItem(name: "highlight_fields", value: highlightFields))
        }

        if let preSegmentedQuery = commonParameters.preSegmentedQuery {
            searchQueryParams.append(URLQueryItem(name: "pre_segmented_query", value: String(preSegmentedQuery)))
        }

        if let preset = commonParameters.preset {
            searchQueryParams.append(URLQueryItem(name: "preset", value: preset))
        }

        if let enableOverrides = commonParameters.enableOverrides {
            searchQueryParams.append(URLQueryItem(name: "enable_overrides", value: String(enableOverrides)))
        }

        if let prioritizeExactMatch = commonParameters.prioritizeExactMatch {
            searchQueryParams.append(URLQueryItem(name: "prioritize_exact_match", value: String(prioritizeExactMatch)))
        }

        if let prioritizeTokenPosition = commonParameters.prioritizeTokenPosition {
            searchQueryParams.append(URLQueryItem(name: "prioritize_token_position", value: String(prioritizeTokenPosition)))
        }

        if let prioritizeNumMatchingFields = commonParameters.prioritizeNumMatchingFields {
            searchQueryParams.append(URLQueryItem(name: "prioritize_num_matching_fields", value: String(prioritizeNumMatchingFields)))
        }

        if let enableTyposForNumericalTokens = commonParameters.enableTyposForNumericalTokens {
            searchQueryParams.append(URLQueryItem(name: "enable_typos_for_numerical_tokens", value: String(enableTyposForNumericalTokens)))
        }

        if let exhaustiveSearch = commonParameters.exhaustiveSearch {
            searchQueryParams.append(URLQueryItem(name: "exhaustive_search", value: String(exhaustiveSearch)))
        }

        if let searchCutoffMs = commonParameters.searchCutoffMs {
            searchQueryParams.append(URLQueryItem(name: "search_cutoff_ms", value: String(searchCutoffMs)))
        }

        if let useCache = commonParameters.useCache {
            searchQueryParams.append(URLQueryItem(name: "use_cache", value: String(useCache)))
        }

        if let cacheTtl = commonParameters.cacheTtl {
            searchQueryParams.append(URLQueryItem(name: "cache_ttl", value: String(cacheTtl)))
        }

        if let minLen1typo = commonParameters.minLen1typo {
            searchQueryParams.append(URLQueryItem(name: "min_len1type", value: String(minLen1typo)))
        }

        if let minLen2typo = commonParameters.minLen2typo {
            searchQueryParams.append(URLQueryItem(name: "min_len2type", value: String(minLen2typo)))
        }

        if let vectorQuery = commonParameters.vectorQuery {
            searchQueryParams.append(URLQueryItem(name: "vector_query", value: vectorQuery))
        }

        if let remoteEmbeddingTimeoutMS = commonParameters.remoteEmbeddingTimeoutMs {
            searchQueryParams.append(URLQueryItem(name: "remote_embedding_timeout_ms", value: String(remoteEmbeddingTimeoutMS)))
        }

        if let remoteEmbeddingNumTries = commonParameters.remoteEmbeddingNumTries {
            searchQueryParams.append(URLQueryItem(name: "remote_embedding_num_tries", value: String(remoteEmbeddingNumTries)))
        }

        if let facetStrategy = commonParameters.facetStrategy {
            searchQueryParams.append(URLQueryItem(name: "facet_strategy", value: facetStrategy))
        }

        if let stopwords = commonParameters.stopwords {
            searchQueryParams.append(URLQueryItem(name: "stopwords", value: stopwords))
        }

        if let facetReturnParent = commonParameters.facetReturnParent {
            searchQueryParams.append(URLQueryItem(name: "facet_strategy", value: facetReturnParent))
        }

        let searches = MultiSearchSearchesParameter(searches: searchRequests)

        let searchesData = try encoder.encode(searches)

        let (data, response) = try await apiCall.post(endPoint: "\(RESOURCEPATH)", body: searchesData, queryParameters: searchQueryParams)

        if let validData = data {
            let searchRes = try decoder.decode(MultiSearchResult<T>.self, from: validData)
            return (searchRes, response)
        }

        return (nil, response)
    }
}
