import XCTest
@testable import Typesense

final class AnalyticsTests: XCTestCase {
    override func setUp() async throws  {
        let _ = try await utilClient.collections().create(schema: CollectionSchema(fields: [
            Field(name:"q", type: "string"),
            Field(name:"count", type: "int32")
        ], name: "product_queries"))
        let _ = try await utilClient.collections().create(schema: CollectionSchema(fields: [
            Field(name:"name", type: "string"),
            Field(name:"in_stock", type: "int32")
        ], name: "products"))
        try await createAnalyticRule()
    }

    override func tearDown() async throws  {
       try await tearDownAnalyticsRules()
       try await tearDownCollections()
    }

    func testAnalyticsRuleCreate() async {
        let schema = AnalyticsRuleCreate(
            collection: "products",
            eventType: "search",
            name: "test-rule",
            type: .popularQueries,
            params: AnalyticsRuleCreateParams(
                destinationCollection: "product_queries",
                limit: 100,
            ),
            ruleTag: "homepage",
        )
        do {
            let (rule, _) = try await utilClient.analytics().rules().create(schema)
            XCTAssertNotNil(rule)
            guard let validRule = rule else {
                throw DataError.dataNotFound
            }
            print(validRule)
            XCTAssertEqual(validRule.name, schema.name)
            XCTAssertEqual(validRule.params?.limit, schema.params?.limit)
            XCTAssertEqual(validRule.params?.destinationCollection, schema.params?.destinationCollection)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
    
    func testAnalyticsRuleCreateMany() async {
        let schema1 = AnalyticsRuleCreate(
            collection: "test_rule_1",
            eventType: "search",
            name: "products",
            type: .popularQueries,
            params: AnalyticsRuleCreateParams(
                destinationCollection: "product_queries",
                limit: 100,
            ),
            ruleTag: "homepage"
        )
        let schema2 = AnalyticsRuleCreate(
            collection: "products",
            eventType: "any",
            name: "test_rule_2",
            type: .popularQueries,
            params: AnalyticsRuleCreateParams(
                destinationCollection: "product_queries",
                limit: 100,
            ),
            ruleTag: "homepage",
        )

        do {
            let (rules, _) = try await utilClient.analytics().rules().createMany([schema1, schema2])
            XCTAssertNotNil(rules)
            guard let validRule = rules else {
                throw DataError.dataNotFound
            }
            print(validRule)
            XCTAssertEqual(validRule[0].name, schema1.name)
            XCTAssertEqual(validRule[1].name, schema2.name)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testAnalyticsRuleRetrieve() async {
        do {
            let (rule, _) = try await client.analytics().rule("homepage_popular_queries").retrieve()
            guard let validRule = rule else {
                throw DataError.dataNotFound
            }
            print(validRule)
            XCTAssertEqual(validRule.name, "homepage_popular_queries")
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testAnalyticsRuleRetrieveAll() async {
        do {
            let (rules, _) = try await client.analytics().rules().retrieveAll()
            XCTAssertNotNil(rules)
            guard let validRules = rules else {
                throw DataError.dataNotFound
            }
            print(validRules)
            XCTAssertEqual(validRules[0].name, "homepage_popular_queries")
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testAnalyticsRuleDelete() async {
        do {
            let (deletedRule, _) = try await client.analytics().rule( "homepage_popular_queries").delete()
            XCTAssertNotNil(deletedRule)
            guard let validRule = deletedRule else {
                throw DataError.dataNotFound
            }
            print(validRule)
            XCTAssertEqual(validRule.name, "homepage_popular_queries")
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testAnalyticsEventsCreate() async {
        do {
            let (res, _) = try await client.analytics().events().create( AnalyticsEvent(
                data: AnalyticsEventData(
                    q: "nike shoes",
                    userId: "111112",
                ),
                eventType: "popular_queries",
                name: "product_queries_aggregation",
            ))
            guard let validRes = res else {
                throw DataError.dataNotFound
            }
            print(validRes)
            XCTAssertTrue(validRes.ok)
        }  catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }
}
