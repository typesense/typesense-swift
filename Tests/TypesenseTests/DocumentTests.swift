import XCTest
@testable import Typesense

final class DocumentTests: XCTestCase {
    func testDocumentCreate() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)
        
        //Example Struct to match the Companies Collection
        struct Company: Codable {
            var id: String
            var company_name: String
            var num_employees: Int
            var country: String
        }
        
        let document = Company(id: "125", company_name: "Stark Industries", num_employees: 5215, country: "USA")

        do {
            let docuData = try encoder.encode(document)
            print(String(data: docuData, encoding: .utf8)!)
            let _ = try await client.collection(name: "companies").documents().create(document: docuData)
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
        
        //Example Struct to match the Companies Collection
        struct Company: Codable {
            var id: String
            var company_name: String
            var num_employees: Int
            var country: String
        }
        
        let document = Company(id: "124", company_name: "Stark Industries", num_employees: 5215, country: "USA")

        do {
            let docuData = try encoder.encode(document)
            print(String(data: docuData, encoding: .utf8)!)
            let _ = try await client.collection(name: "companies").documents().upsert(document: docuData)
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
            let _ = try await client.collection(name: "companies").documents().delete(id: "125")
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
        
        //Example Struct to match the Companies Collection
        struct Company: Codable {
            var id: String
            var company_name: String
            var num_employees: Int
            var country: String
        }
        
        do {
            let (data, _) = try await client.collection(name: "companies").documents().retrieve(id: "125")
            guard let validData = data else {
                throw DataError.unableToParse
            }
            
            let doc = try decoder.decode(Company.self, from: validData)
            print(doc)
            
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
}
