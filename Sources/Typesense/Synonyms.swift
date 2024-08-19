import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct Synonyms {
    var apiCall: ApiCall
    var collectionName: String
    let RESOURCEPATH: String

    init(apiCall: ApiCall, collectionName: String) {
        self.apiCall = apiCall
        self.collectionName = collectionName
        self.RESOURCEPATH = "collections/\(collectionName)/synonyms"
    }

    public func upsert(id: String, _ searchSynonym: SearchSynonymSchema) async throws -> (SearchSynonym?, URLResponse?) {
        var schemaData: Data? = nil

        schemaData = try encoder.encode(searchSynonym)

        if let validSchema = schemaData {
            let (data, response) = try await apiCall.put(endPoint: "\(RESOURCEPATH)/\(id)", body: validSchema)
            if let result = data {
                let synonym = try decoder.decode(SearchSynonym.self, from: result)
                return (synonym, response)
            }

        }
        return (nil, nil)
    }

    public func retrieve(id: String) async throws -> (SearchSynonym?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: "\(RESOURCEPATH)/\(id)")
        if let result = data {
            let synonym = try decoder.decode(SearchSynonym.self, from: result)
            return (synonym, response)
        }
        return (nil, nil)
    }

    public func retrieve() async throws -> (SearchSynonymsResponse?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: "\(RESOURCEPATH)")
        if let result = data {
            let synonym = try decoder.decode(SearchSynonymsResponse.self, from: result)
            return (synonym, response)
        }
        return (nil, nil)
    }

    public func delete(id: String) async throws -> (Data?, URLResponse?) {
        let (data, response) = try await apiCall.get(endPoint: "\(RESOURCEPATH)")
        return (data, response)
    }

}
