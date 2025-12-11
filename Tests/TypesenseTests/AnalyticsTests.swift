import XCTest
@testable import Typesense

final class AnalyticsTests: XCTestCase {
    override func setUp() async throws  {
        let _ = try await client.collections().create(schema: CollectionSchema(name: "product_queries", fields: [
            Field(name:"q", type: "string"),
            Field(name:"count", type: "int32")
        ]))
        let _ = try await client.collections().create(schema: CollectionSchema(name: "test-products-analytics", fields: [
            Field(name:"name", type: "string"),
            Field(name:"in_stock", type: "int32")
        ]))
        let _ = try await client.analytics().rules().create(AnalyticsRuleCreate(
            name: "homepage_popular_queries",
            type: .popularQueries,
            collection: "test-products-analytics",
            eventType: "search",
            ruleTag: "homepage",
            params: AnalyticsRuleCreateParams(
                destinationCollection: "product_queries",
                limit: 100,
                captureSearchRequests: true,
            ),

        ))
    }

    override func tearDown() async throws  {
       try await tearDownAnalyticsRules()
       try await tearDownCollections()
    }

    func testAnalyticsRuleCreate() async {
        let schema = AnalyticsRuleCreate(
            name: "test-rule",
            type: .popularQueries,
            collection: "test-products-analytics",
            eventType: "search",
            ruleTag: "homepage",
            params: AnalyticsRuleCreateParams(
                destinationCollection: "product_queries",
                limit: 100,
            ),
        )
        do {
            let (rule, _) = try await client.analytics().rules().create(schema)
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
            name: "test_rule_1",
            type: .popularQueries,
            collection: "test-products-analytics",
            eventType: "search",
            ruleTag: "homepage",
            params: AnalyticsRuleCreateParams(
                destinationCollection: "product_queries",
                limit: 100,
            ),
        )
        let schema2 = AnalyticsRuleCreate(
            name: "test_rule_2",
            type: .popularQueries,
            collection: "test-products-analytics",
            eventType: "search",
            ruleTag: "homepage",
            params: AnalyticsRuleCreateParams(
                destinationCollection: "product_queries",
                limit: 100,
            ),
        )
        do {
            let (rules, _) = try await client.analytics().rules().createMany([schema1, schema2])
            XCTAssertNotNil(rules)
            guard let validRule = rules else {
                throw DataError.dataNotFound
            }
            print(validRule)
            if case let .success(firstRule) = validRule[0], case let .success(secondRule) = validRule[1] {
                XCTAssertEqual(firstRule.name, schema1.name)
                XCTAssertEqual(secondRule.name, schema2.name)
            } else {
                XCTFail("Both rules should be of type AnalyticsRule")
            }
        } catch (let error) {
            print(error)
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
                name: "homepage_popular_queries",
                eventType: "popular_queries",
                data: AnalyticsEventData(
                    userId: "111112", q: "nike shoes",
                ),
            ))
            guard let validRes = res else {
                throw DataError.dataNotFound
            }
            print(validRes)
            XCTAssertTrue(validRes.ok)
        }  catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testAnalyticsEventsRetrieve() async {
        do {
            let (res, _) = try await client.analytics().events().retrieve(
                AnalyticsEventsRetrieveParams(userId: "123", name: "homepage_popular_queries", n:10))
            guard let validRes = res else {
                throw DataError.dataNotFound
            }
            print(validRes)
            XCTAssertEqual(validRes.events.count, 0)
        }  catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

}
