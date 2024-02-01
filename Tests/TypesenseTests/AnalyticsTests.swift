import XCTest
@testable import Typesense

final class AnalyticsTests: XCTestCase {

    func testAnalyticsRuleCreate() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        let client = Client(config: config)
        
        let destination = AnalyticsRuleParametersDestination(collection: "product_queries")
        let source = AnalyticsRuleParametersSource(collections: ["products"])
        let schema = AnalyticsRuleSchema(name: "product_queries_aggregation", type: "popular_queries", params: AnalyticsRuleParameters(source: source, destination: destination, limit: 1000))
        do {
            let (rule, _) = try await client.analytics().rules().create(params: schema)
            XCTAssertNotNil(rule)
            guard let validRule = rule else {
                throw DataError.dataNotFound
            }
            print(validRule)
            XCTAssertEqual(validRule.name, schema.name)
            XCTAssertEqual(validRule.params.limit, schema.params.limit)
            XCTAssertEqual(validRule.params.destination.collection, schema.params.destination.collection)
        } catch (let error) {
            print("ERROR", error)
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
    func testAnalyticsRuleRetrieve() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        let client = Client(config: config)
        
        do {
            let (rule, _) = try await client.analytics().rule(id: "product_queries_aggregation").retrieve()
            guard let validRule = rule else {
                throw DataError.dataNotFound
            }
            print(validRule)
            XCTAssertEqual(validRule.name, "product_queries_aggregation")
        } catch ResponseError.analyticsRuleDoesNotExist(let desc) {
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
    
    func testAnalyticsRuleRetrieveAll() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        let client = Client(config: config)
        
        do {
            let (rules, _) = try await client.analytics().rules().retrieveAll()
            XCTAssertNotNil(rules)
            guard let validRules = rules else {
                throw DataError.dataNotFound
            }
            print(validRules)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
    func testAnalyticsRuleDelete() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
        
        let client = Client(config: config)
        
        do {
            let (deletedRule, _) = try await client.analytics().rule(id: "product_queries_aggregation").delete()
            XCTAssertNotNil(deletedRule)
            guard let validRule = deletedRule else {
                throw DataError.dataNotFound
            }
            print(validRule)
            XCTAssertEqual(validRule.name, "product_queries_aggregation")
        } catch ResponseError.analyticsRuleDoesNotExist(let desc) {
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
}
