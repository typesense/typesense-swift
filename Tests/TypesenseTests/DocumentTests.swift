import XCTest
@testable import Typesense

final class DocumentTests: XCTestCase {
    func testDocumentCreate() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        
        let client = Client(config: config)
        let document = """
            {
                "id": "125",
                "company_name": "Stark Industries",
                "num_employees": 5215,
                "country": "USA"
            }
        """
        
        do {
            let docuData = try encoder.encode(document)
            let _ = try await client.collection(name: "companies").documents().create(document: docuData)
            
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
}
