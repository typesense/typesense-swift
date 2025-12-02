import XCTest
@testable import Typesense

final class SynonymTests: XCTestCase {
    func testSynonymUpsertMultiWay() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)
        
        do {
           
            let synonymSchema = SearchSynonymSchema(synonyms: ["blazer", "coat", "jacket"])
            let (_, _) = try await myClient.collections().create(schema: CollectionSchema(fields: [Field(name: "name", type: "string")],name: "products")) //Creating test collection - Products
        
            let (data, _) = try await myClient.collection(name: "products").synonyms().upsert(id: "coat-synonyms", synonymSchema)
            let (_,_) = try await myClient.collection(name: "products").delete() //Deleting test collection
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertNil(validData.root)
            XCTAssertEqual(validData.synonyms, ["blazer", "coat", "jacket"])
            XCTAssertEqual(validData.id, "coat-synonyms")
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }
    
    func testSynonymUpsertOneWay() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)
        
        do {
           
            let synonymSchema = SearchSynonymSchema( synonyms: ["iphone", "android"],root: "smart phone",)
            let (_, _) = try await myClient.collections().create(schema: CollectionSchema(fields: [Field(name: "name", type: "string")], name: "products", )) //Creating test collection - Products
        
            let (data, _) = try await myClient.collection(name: "products").synonyms().upsert(id: "smart-phone-synonyms", synonymSchema)
            let (_,_) = try await myClient.collection(name: "products").delete() //Deleting test collection
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.root, "smart phone")
            XCTAssertEqual(validData.synonyms, ["iphone", "android"])
            XCTAssertEqual(validData.id, "smart-phone-synonyms")
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }
    
    func testSynonymRetrieveOne() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)
        
        do {
           
            let synonymSchema = SearchSynonymSchema(synonyms: ["blazer", "coat", "jacket"])
            let (_, _) = try await myClient.collections().create(schema: CollectionSchema(fields: [Field(name: "name", type: "string")], name: "products",)) //Creating test collection - Products
            let (_, _) = try await myClient.collection(name: "products").synonyms().upsert(id: "coat-synonyms", synonymSchema) //Feed in the synonym
            let (data,_) = try await myClient.collection(name: "products").synonyms().retrieve(id: "coat-synonyms")
            let (_,_) = try await myClient.collection(name: "products").delete() //Deleting test collection
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.root, "")
            XCTAssertEqual(validData.synonyms, ["blazer", "coat", "jacket"])
            XCTAssertEqual(validData.id, "coat-synonyms")
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }
    
    func testSynonymRetrieveAll() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)
        
        do {
           
            let synonymSchema = SearchSynonymSchema(synonyms: ["blazer", "coat", "jacket"])
            let (_, _) = try await myClient.collections().create(schema: CollectionSchema(fields: [Field(name: "name", type: "string")], name: "products", )) //Creating test collection - Products
            let (_, _) = try await myClient.collection(name: "products").synonyms().upsert(id: "coat-synonyms", synonymSchema) //Feed in the synonym
            let (data,_) = try await myClient.collection(name: "products").synonyms().retrieve()
            let (_,_) = try await myClient.collection(name: "products").delete() //Deleting test collection
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.synonyms.count, 1)
            XCTAssertEqual(validData.synonyms[0].id, "coat-synonyms")
            XCTAssertEqual(validData.synonyms[0].synonyms, ["blazer", "coat", "jacket"])
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }
    
    func testSynonymDelete() async {
        let newConfig = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let myClient = Client(config: newConfig)
        
        do {
           
            let synonymSchema = SearchSynonymSchema(synonyms: ["blazer", "coat", "jacket"])
            let (_, _) = try await myClient.collections().create(schema: CollectionSchema(
                fields: [Field(name: "name", type: "string")],
                name: "products",
            )) //Creating test collection - Products
            let (_, _) = try await myClient.collection(name: "products").synonyms().upsert(id: "coat-synonyms", synonymSchema) //Feed in the synonym
            let (data,_) = try await myClient.collection(name: "products").synonyms().delete(id: "coat-synonyms")
            let (_,_) = try await myClient.collection(name: "products").delete() //Deleting test collection
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(String(data: validData, encoding: .utf8)!)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false) //To prevent this, check availability of Typesense Server and retry
        }
    }
}
