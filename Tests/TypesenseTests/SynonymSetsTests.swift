import XCTest
@testable import Typesense

final class SynonymSetsTests: XCTestCase {
    
    override func setUp() async throws  {
       try await createSynonymSet()
    }
    
    override func tearDown() async throws  {
       try await tearDownSynonymSets()
    }

    func testSynonymRetrieveOne() async {
        do {
            let (data,_) = try await utilClient.synonymSet("clothing-synonyms").retrieve()
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "clothing-synonyms")
            XCTAssertEqual(validData.items[0].synonyms, ["blazer", "coat", "jacket"])
            XCTAssertEqual(validData.items[0].id, "coat-synonyms")
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testSynonymRetrieveAll() async {
        do {
            let (data,_) = try await utilClient.synonymSets().retrieve()
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.count, 1)
            XCTAssertEqual(validData[0].name, "clothing-synonyms")
            XCTAssertEqual(validData[0].items[0].synonyms, ["blazer", "coat", "jacket"])
            XCTAssertEqual(validData[0].items[0].id, "coat-synonyms")
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
    func testSynonymSetDelete() async {
        do {
            let (data,_) = try await utilClient.synonymSet("clothing-synonyms").delete()
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.name, "clothing-synonyms")
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
        
        do{
            let _ = try await client.synonymSet("clothing-synonyms").retrieve()
        } catch HTTPError.clientError(let code, _){
            if code != 404 {
                XCTAssertTrue(false, "Synonym set should have been deleted")
            }
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }
    
    func testSynonymSetItemRetrieveOne() async {
        do {
            let (data,_) = try await utilClient.synonymSet("clothing-synonyms").item("coat-synonyms").retrieve()
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.synonyms, ["blazer", "coat", "jacket"])
            XCTAssertEqual(validData.id, "coat-synonyms")
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
    func testSynonymSetItemDelete() async {
        do {
            let (data,_) = try await utilClient.synonymSet("clothing-synonyms").item("coat-synonyms").delete()
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.id, "coat-synonyms")
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
        do{
            let _ = try await utilClient.synonymSet("clothing-synonyms").item("coat-synonyms").retrieve()
        } catch HTTPError.clientError(let code, _){
            if code != 404 {
                XCTAssertTrue(false, "Synonym set item should have been deleted")
            }
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }
    
    func testSynonymSetItemUpsert() async {
        do {
            let (data,_) = try await utilClient.synonymSet("clothing-synonyms").items().upsert("coat-synonyms-2", SynonymItemUpsertSchema(synonyms: ["none"]))
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.synonyms, ["none"])
            XCTAssertEqual(validData.id, "coat-synonyms-2")
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testSynonymSetItemRetrieveAll() async {
        do {
            let (data,_) = try await utilClient.synonymSet("clothing-synonyms").items().retrieve()
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            XCTAssertEqual(validData.count, 1)
            XCTAssertEqual(validData[0].synonyms, ["blazer", "coat", "jacket"])
            XCTAssertEqual(validData[0].id, "coat-synonyms")
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
}
