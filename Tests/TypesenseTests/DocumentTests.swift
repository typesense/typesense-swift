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
    
    //Partial data format to be used in update() method
    struct PartialCompany: Codable {
        var id: String?
        var company_name: String?
        var num_employees: Int?
        var country: String?
    }
    
    func testDocumentCreate() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)
        
        let document = Company(id: "125", company_name: "Stark Industries", num_employees: 5215, country: "USA")

        do {
            let docuData = try encoder.encode(document)
            let (data, _) = try await client.collection(name: "companies").documents().create(document: docuData)
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            let docuResp = try decoder.decode(Company.self, from: validResp)
            XCTAssertEqual(docuResp.company_name, "Stark Industries")
            XCTAssertEqual(docuResp.num_employees, 5215)
            XCTAssertEqual(docuResp.id, "125")
            XCTAssertEqual(docuResp.country, "USA")
            print(docuResp)
            
        } catch ResponseError.documentAlreadyExists(let desc), ResponseError.invalidCollection(let desc) {
            print(desc)
            XCTAssertTrue(true)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
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
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            let docuResp = try decoder.decode(Company.self, from: validResp)
            XCTAssertEqual(docuResp.company_name, "Stark Industries")
            XCTAssertEqual(docuResp.num_employees, 5215)
            XCTAssertEqual(docuResp.id, "124")
            XCTAssertEqual(docuResp.country, "USA")
            print(docuResp)
        } catch ResponseError.documentAlreadyExists(let desc), ResponseError.invalidCollection(let desc) {
            print(desc)
            XCTAssertTrue(true)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
    func testDocumentDelete() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)
        
        do {
            let (data, _) = try await client.collection(name: "companies").document(id: "125").delete()
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            
            let docuResp = try decoder.decode(Company.self, from: validResp)
            XCTAssertEqual(docuResp.company_name, "Stark Industries")
            let emps = [5215, 5500]
            XCTAssertTrue(emps.contains(docuResp.num_employees))
            XCTAssertEqual(docuResp.id, "125")
            XCTAssertEqual(docuResp.country, "USA")
            print(docuResp)
            
        } catch ResponseError.documentDoesNotExist(let desc), ResponseError.invalidCollection(let desc) {
            print(desc)
            XCTAssertTrue(true)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
    func testDocumentRetrieve() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)
        
        do {
            let (data, _) = try await client.collection(name: "companies").document(id: "125").retrieve()
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            
            let docuResp = try decoder.decode(Company.self, from: validResp)
            XCTAssertEqual(docuResp.company_name, "Stark Industries")
            let emps = [5215, 5500]
            XCTAssertTrue(emps.contains(docuResp.num_employees))
            XCTAssertEqual(docuResp.id, "125")
            XCTAssertEqual(docuResp.country, "USA")
            print(docuResp)
            
        } catch ResponseError.documentDoesNotExist(let desc), ResponseError.invalidCollection(let desc) {
            print(desc)
            XCTAssertTrue(true)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
    func testDocumentUpdate() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)
        
        let newDoc = PartialCompany(company_name: "Stark Industries", num_employees: 5500)
        
        do {
            let docuData = try encoder.encode(newDoc)
            let (data, _) = try await client.collection(name: "companies").document(id: "125").update(newDocument: docuData)
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            
            let docuResp = try decoder.decode(Company.self, from: validResp)
            XCTAssertEqual(docuResp.company_name, "Stark Industries")
            XCTAssertEqual(docuResp.num_employees, 5500)
            XCTAssertEqual(docuResp.id, "125")
            XCTAssertEqual(docuResp.country, "USA")
            print(docuResp)
            
        } catch ResponseError.documentDoesNotExist(let desc), ResponseError.invalidCollection(let desc) {
            print(desc)
            XCTAssertTrue(true)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
    func testDocumentSearch() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)
        
        let searchParams = SearchParameters(q: "stark", queryBy: "company_name", filterBy: "num_employees:>100", sortBy: "num_employees:desc")
        
        do {
            let (data, _) = try await client.collection(name: "companies").documents().search(searchParams, for: Company.self)
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            if let gotSomeHits = validResp.hits {
                XCTAssertNotNil(validResp.hits)
                XCTAssertNotNil(validResp.found)
                XCTAssertNotNil(gotSomeHits[0].textMatch)
                XCTAssertNotNil(gotSomeHits[0].document)
                XCTAssertNotNil(gotSomeHits[0].highlights?[0].matchedTokens)
            }
            print(validResp)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
        
    }
    
    func testDocumentImport() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)
        
        let documents = [
            Company(id: "124", company_name: "Stark Industries", num_employees: 5125, country: "USA"),
            Company(id: "125", company_name: "Acme Corp", num_employees: 2133, country: "CA")
        ]
        
        do {
            
            var jsonLStrings:[String] = []
            for doc in documents {
                let data = try encoder.encode(doc)
                let str = String(data: data, encoding: .utf8)!
                jsonLStrings.append(str)
            }

            let jsonLString = jsonLStrings.joined(separator: "\n")
            print(jsonLString)
            let jsonL = Data(jsonLString.utf8)
        
            let (data, _) = try await client.collection(name: "companies").documents().importBatch(jsonL)
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            print(String(data: validResp, encoding: .utf8) ?? "Unable to Parse JSONL")
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
}
