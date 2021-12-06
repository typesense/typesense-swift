import Foundation

public struct Documents {
    var apiCall: ApiCall
    var collectionName: String?
    let RESOURCEPATH: String
    
    public init(config: Configuration, collectionName: String) {
        apiCall = ApiCall(config: config)
        self.collectionName = collectionName
        self.RESOURCEPATH = "collections/\(collectionName)/documents"
    }
    
    func create(document: Data) async throws -> (Data?, Int?) {
        let (data, statusCode) = try await apiCall.post(endPoint: RESOURCEPATH, body: document)
        return (data, statusCode)
    }
    
    func upsert(document: Data) async throws -> (Data?, Int?) {
        let upsertAction = URLQueryItem(name: "action", value: "upsert")
        let (data, statusCode) = try await apiCall.post(endPoint: RESOURCEPATH, body: document, queryParameters: [upsertAction])
        return (data, statusCode)
    }
    
    func delete(id: String) async throws -> (Data?, Int?) {
        let (data, statusCode) = try await apiCall.delete(endPoint: "\(RESOURCEPATH)/\(id)")
        return (data, statusCode)
    }
    
    func retrieve(id: String) async throws -> (Data?, Int?) {
        let (data, statusCode) = try await apiCall.get(endPoint: "\(RESOURCEPATH)/\(id)")
        return (data, statusCode)
    }
    
    func search(_ searchParameters: SearchParameters) async throws -> (SearchResult?, Int?) {
        var searchQueryParams: [URLQueryItem] =
        [
            URLQueryItem(name: "q", value: searchParameters.q),
            URLQueryItem(name: "query_by", value: searchParameters.queryBy.joined(separator: ",")),
        ]
        
        if let queryByWeights = searchParameters.queryByWeights {
            searchQueryParams.append(URLQueryItem(name: "query_by_weights", value: queryByWeights.joined(separator: ",")))
        }
        
        if let maxHits = searchParameters.maxHits {
            searchQueryParams.append(URLQueryItem(name: "max_hits", value: maxHits))
        }
        
        if let _prefix = searchParameters._prefix {
            var fullString = ""
            for item in _prefix {
                fullString.append(String(item))
                fullString.append(",")
            }
            
            searchQueryParams.append(URLQueryItem(name: "prefix", value: String(fullString.dropLast())))
        }
        
        if let filterBy = searchParameters.filterBy {
            searchQueryParams.append(URLQueryItem(name: "filter_by", value: filterBy))
        }
        
        if let sortBy = searchParameters.sortBy {
            searchQueryParams.append(URLQueryItem(name: "sort_by", value: sortBy.joined(separator: ",")))
        }
        
        if let facetBy = searchParameters.facetBy {
            searchQueryParams.append(URLQueryItem(name: "facet_by", value: facetBy.joined(separator: ",")))
        }
        
        if let maxFacetValues = searchParameters.maxFacetValues {
            searchQueryParams.append(URLQueryItem(name: "max_facet_values", value: String(maxFacetValues)))
        }
        
        if let facetQuery = searchParameters.facetQuery {
            searchQueryParams.append(URLQueryItem(name: "facet_query", value: facetQuery))
        }
        
        if let numTypos = searchParameters.numTypos {
            searchQueryParams.append(URLQueryItem(name: "num_typos", value: String(numTypos)))
        }
        
        if let page = searchParameters.page {
            searchQueryParams.append(URLQueryItem(name: "page", value: String(page)))
        }
        
        if let perPage = searchParameters.perPage {
            searchQueryParams.append(URLQueryItem(name: "per_page", value: String(perPage)))
        }
        
        if let groupBy = searchParameters.groupBy {
            searchQueryParams.append(URLQueryItem(name: "group_by", value: groupBy.joined(separator: ",")))
        }
        
        if let groupLimit = searchParameters.groupLimit {
            searchQueryParams.append(URLQueryItem(name: "group_limit", value: String(groupLimit)))
        }
        
        if let includeFields = searchParameters.includeFields {
            searchQueryParams.append(URLQueryItem(name: "include_fields", value: includeFields.joined(separator: ",")))
        }
        
        if let excludeFields = searchParameters.excludeFields {
            searchQueryParams.append(URLQueryItem(name: "exclude_fields", value: excludeFields.joined(separator: ",")))
        }
        
        if let highlightFullFields = searchParameters.highlightFullFields {
            searchQueryParams.append(URLQueryItem(name: "highlight_full_fields", value: highlightFullFields.joined(separator: ",")))
        }
        
        if let highlightAffixNumTokens = searchParameters.highlightAffixNumTokens {
            searchQueryParams.append(URLQueryItem(name: "highlight_affix_num_tokens", value: String(highlightAffixNumTokens)))
        }
        
        if let highlightStartTag = searchParameters.highlightStartTag {
            searchQueryParams.append(URLQueryItem(name: "highlight_start_tag", value: highlightStartTag))
        }
        
        if let highlightEndTag = searchParameters.highlightEndTag {
            searchQueryParams.append(URLQueryItem(name: "highlight_end_tag", value: highlightEndTag))
        }
        
        if let snippetThreshold = searchParameters.snippetThreshold {
            searchQueryParams.append(URLQueryItem(name: "snippet_threshold", value: String(snippetThreshold)))
        }
        
        if let dropTokensThreshold = searchParameters.dropTokensThreshold {
            searchQueryParams.append(URLQueryItem(name: "drop_tokens_threshold", value: String(dropTokensThreshold)))
        }
        
        if let typoTokensThreshold = searchParameters.typoTokensThreshold {
            searchQueryParams.append(URLQueryItem(name: "typo_tokens_threshold", value: String(typoTokensThreshold)))
        }
        
        if let pinnedHits = searchParameters.pinnedHits {
            searchQueryParams.append(URLQueryItem(name: "pinned_hits", value: pinnedHits.joined(separator: ",")))
        }
        
        if let hiddenHits = searchParameters.hiddenHits {
            searchQueryParams.append(URLQueryItem(name: "hidden_hits", value: hiddenHits.joined(separator: ",")))
        }
        
        if let highlightFields = searchParameters.highlightFields {
            searchQueryParams.append(URLQueryItem(name: "highlight_fields", value: highlightFields.joined(separator: ",")))
        }
        
        if let preSegmentedQuery = searchParameters.preSegmentedQuery {
            searchQueryParams.append(URLQueryItem(name: "pre_segmented_query", value: String(preSegmentedQuery)))
        }
        
        if let enableOverrides = searchParameters.enableOverrides {
            searchQueryParams.append(URLQueryItem(name: "enable_overrides", value: String(enableOverrides)))
        }
        
        if let prioritizeExactMatch = searchParameters.prioritizeExactMatch {
            searchQueryParams.append(URLQueryItem(name: "prioritize_exact_match", value: String(prioritizeExactMatch)))
        }
        
        if let exhaustiveSearch = searchParameters.exhaustiveSearch {
            searchQueryParams.append(URLQueryItem(name: "exhaustive_search", value: String(exhaustiveSearch)))
        }
        
        if let searchCutoffMs = searchParameters.searchCutoffMs {
            searchQueryParams.append(URLQueryItem(name: "search_cutoff_ms", value: String(searchCutoffMs)))
        }
        
        if let useCache = searchParameters.useCache {
            searchQueryParams.append(URLQueryItem(name: "use_cache", value: String(useCache)))
        }
        
        if let cacheTtl = searchParameters.cacheTtl {
            searchQueryParams.append(URLQueryItem(name: "cache_ttl", value: String(cacheTtl)))
        }
        
        if let minLen1typo = searchParameters.minLen1typo {
            searchQueryParams.append(URLQueryItem(name: "min_len1type", value: String(minLen1typo)))
        }
        
        if let minLen2typo = searchParameters.minLen2typo {
            searchQueryParams.append(URLQueryItem(name: "min_len2type", value: String(minLen2typo)))
        }
        

        let (data, statusCode) = try await apiCall.get(endPoint: "\(RESOURCEPATH)/search", queryParameters: searchQueryParams)

        if let validData = data {
            let searchRes = try decoder.decode(SearchResult.self, from: validData)
            return (searchRes, statusCode)
        }

        return (nil, statusCode)
    }

}
