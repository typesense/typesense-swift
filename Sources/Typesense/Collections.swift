import Foundation

let RESOURCEPATH = "collections"

public struct Collections {
    var apiCall: ApiCall
    
    public init(config: Configuration) {
        apiCall = ApiCall(config: config)
    }
    
    mutating func create(schema: CollectionSchema) async -> (Data?, Int?) {
        var schemaData: Data? = nil
        do {
            schemaData = try encoder.encode(schema)
            
            if let validSchema = schemaData {
                let (data, statusCode) = try await apiCall.post(endPoint: RESOURCEPATH, body: validSchema)
                return (data, statusCode)
            }
        } catch (let error) {
            print(error.localizedDescription)
        }
        return (nil, nil)
    }
    
    mutating func retrieveAll() async -> ([CollectionResponse]?, Int?) {
        do {
            let (data, statusCode) = try await apiCall.get(endPoint: RESOURCEPATH)
            if let result = data {
                let fetchedCollections = try decoder.decode([CollectionResponse].self, from: result)
                return (fetchedCollections, statusCode)
            }
            
            return (nil, statusCode)
            
        } catch (let error) {
            print(error.localizedDescription)
        }
        
        return (nil, nil)
    }
    
    mutating func delete(name: String) async -> (Data?, Int?) {
        do {
            let (data, statusCode) = try await apiCall.delete(endPoint: "\(RESOURCEPATH)/\(name)")
            return (data, statusCode)
        } catch (let error) {
            print(error.localizedDescription)
        }
        return (nil, nil)
    }
    
    mutating func retrieve(name: String) async -> (CollectionResponse?, Int?) {
        do {
            let (data, statusCode) = try await apiCall.get(endPoint: "\(RESOURCEPATH)/\(name)")
            if let result = data {
                let fetchedCollection = try decoder.decode(CollectionResponse.self, from: result)
                return (fetchedCollection, statusCode)
            }
            return (nil, statusCode)
        } catch (let error) {
            print(error.localizedDescription)
        }
        return (nil, nil)
    }
}
