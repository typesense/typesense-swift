import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif


public struct Documents {
    var apiCall: ApiCall
    var collectionName: String

    init(apiCall: ApiCall, collectionName: String) {
        self.apiCall = apiCall
        self.collectionName = collectionName
    }

    public func create(document: Data, options: DocumentIndexParameters? = nil) async throws -> (Data?, URLResponse?) {
        let queryParams = try createURLQuery(forSchema: options)
        let (data, response) = try await apiCall.post(endPoint: endpointPath(), body: document, queryParameters: queryParams)
        return (data, response)
    }

    public func upsert(document: Data, options: DocumentIndexParameters? = nil) async throws -> (Data?, URLResponse?) {
        var queryParams = try createURLQuery(forSchema: options)
        queryParams.append(URLQueryItem(name: "action", value: "upsert"))
        let (data, response) = try await apiCall.post(endPoint: endpointPath(), body: document, queryParameters: queryParams)
        return (data, response)
    }

    public func update<T: Codable>(document: T, options: DocumentIndexParameters? = nil) async throws -> (T?, URLResponse?) {
        var queryParams = try createURLQuery(forSchema: options)
        queryParams.append(URLQueryItem(name: "action", value: "update"))
        let jsonData = try encoder.encode(document)
        let (data, response) = try await apiCall.post(endPoint: endpointPath(), body: jsonData, queryParameters: queryParams)
        if let validData = data {
            let decodedData = try decoder.decode(T.self, from: validData)
            return (decodedData, response)
        }
        return (nil, response)
    }

    public func update<T: Encodable>(document: T, options: UpdateDocumentsParameters) async throws -> (UpdateDocuments200Response?, URLResponse?) {
        let queryParams = try createURLQuery(forSchema: options)
        let jsonData = try encoder.encode(document)
        let (data, response) = try await apiCall.patch(endPoint: endpointPath(), body: jsonData, queryParameters: queryParams)
        if let validData = data {
            let decodedData = try decoder.decode(UpdateDocuments200Response.self, from: validData)
            return (decodedData, response)
        }
        return (nil, response)
    }

    public func delete(options: DeleteDocumentsParameters) async throws -> (DeleteDocuments200Response?, URLResponse?) {
        let queryParams = try createURLQuery(forSchema: options)
        let (data, response) = try await apiCall.delete(endPoint: endpointPath(), queryParameters: queryParams)
        if let validData = data {
            let decodedData = try decoder.decode(DeleteDocuments200Response.self, from: validData)
            return (decodedData, response)
        }
        return (nil, response)
    }

    @available(*, deprecated, message: "Use `delete(options: DeleteDocumentsParameters)` instead!")
    public func delete(filter: String, batchSize: Int? = nil) async throws -> (Data?, URLResponse?) {
        var deleteQueryParams: [URLQueryItem] =
        [
            URLQueryItem(name: "filter_by", value: filter)
        ]
        if let givenBatchSize = batchSize {
            deleteQueryParams.append(URLQueryItem(name: "batch_size", value: String(givenBatchSize)))
        }
        let (data, response) = try await apiCall.delete(endPoint: endpointPath(), queryParameters: deleteQueryParams)
        return (data, response)

    }

    public func search(_ searchParameters: SearchParameters) async throws -> (Data?, URLResponse?) {
        let queryParams = try createURLQuery(forSchema: searchParameters)
        return try await apiCall.get(endPoint: endpointPath("search"), queryParameters: queryParams)
    }

    public func search<T>(_ searchParameters: SearchParameters, for: T.Type) async throws -> (SearchResult<T>?, URLResponse?) {
        let queryParams = try createURLQuery(forSchema: searchParameters)
        let (data, response) = try await apiCall.get(endPoint: endpointPath("search"), queryParameters: queryParams)

        if let validData = data {
            let searchRes = try decoder.decode(SearchResult<T>.self, from: validData)
            return (searchRes, response)
        }

        return (nil, response)
    }

    public func importBatch(_ documents: Data, options: ImportDocumentsParameters) async throws -> (Data?, URLResponse?) {
        let queryParams = try createURLQuery(forSchema: options)
        let (data, response) = try await apiCall.post(endPoint: endpointPath("import"), body: documents, queryParameters: queryParams)
        return (data, response)
    }

    @available(*, deprecated, message: "Use `importBatch(_ documents: Data, options: ImportDocumentsParameters)` instead!")
    public func importBatch(_ documents: Data, action: ActionModes? = ActionModes.create) async throws -> (Data?, URLResponse?) {
        var importAction = URLQueryItem(name: "action", value: "create")
        if let specifiedAction = action {
            importAction.value = specifiedAction.rawValue
        }
        let (data, response) = try await apiCall.post(endPoint: endpointPath("import"), body: documents, queryParameters: [importAction])
        return (data, response)
    }

    public func export(options: ExportDocumentsParameters? = nil) async throws -> (Data?, URLResponse?) {
        let searchQueryParams = try createURLQuery(forSchema: options)
        let (data, response) = try await apiCall.get(endPoint: endpointPath("export"), queryParameters: searchQueryParams)
        return (data, response)
    }

    private func endpointPath(_ operation: String? = nil) throws -> String {
        let baseEndpoint = try "collections/\(collectionName.encodeURL())/documents"
        if let operation: String = operation {
            return "\(baseEndpoint)/\(operation)"
        } else {
            return baseEndpoint
        }
    }
}
