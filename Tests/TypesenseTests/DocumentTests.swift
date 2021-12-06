import XCTest
@testable import Typesense

final class DocumentTests: XCTestCase {
    
    //Example Struct to match the Companies Collection
    struct Company: Codable {
        var id: String
        var company_name: String
        var num_employees: Int
        var country: String
    }
    
    func testDocumentCreate() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)
        
        let document = Company(id: "125", company_name: "Stark Industries", num_employees: 5215, country: "USA")

        do {
            let docuData = try encoder.encode(document)
            print(String(data: docuData, encoding: .utf8)!)
            let (data, _) = try await client.collection(name: "companies").documents().create(document: docuData)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            let docuResp = try decoder.decode(Company.self, from: validResp)
            print(docuResp)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    func testDocumentUpsert() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)

        let document = Company(id: "124", company_name: "Stark Industries", num_employees: 5215, country: "USA")

        do {
            let docuData = try encoder.encode(document)
            print(String(data: docuData, encoding: .utf8)!)
            let (data, _) = try await client.collection(name: "companies").documents().upsert(document: docuData)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            let docuResp = try decoder.decode(Company.self, from: validResp)
            print(docuResp)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    func testDocumentDelete() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)
        
        do {
            let (data, _) = try await client.collection(name: "companies").documents().delete(id: "125")
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            let docuResp = try decoder.decode(Company.self, from: validResp)
            print(docuResp)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    func testDocumentRetrieve() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)
        
        do {
            let (data, _) = try await client.collection(name: "companies").documents().retrieve(id: "125")
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            let docuResp = try decoder.decode(Company.self, from: validResp)
            print(docuResp) 
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    func testDocumentSearch() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)
        
        let searchParams = SearchParameters(q: "stark", queryBy: ["company_name","country"], queryByWeights: ["2","1"], maxHits: "all", _prefix: [true,false], filterBy: "num_employees:>100", sortBy: ["num_employees:desc"], facetBy: ["country"], maxFacetValues: 5, facetQuery: "country:India", numTypos: 1, page: 1, perPage: 8, groupBy: ["country"], groupLimit: 3, includeFields: ["company_name","num_employees","country"], highlightFullFields: ["num_employees"])
        
        do {
            let (data, _) = try await client.collection(name: "companies").documents().search(searchParams)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            print(validResp)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
        
    }
    
}
