import XCTest
@testable import Typesense

final class OverridesTests: XCTestCase {

    override func tearDown() async throws  {
       try! await tearDownCollections()
    }

    func testOverridesUpsert() async {
        try? await setUpCollection()
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let client = Client(config: config)

        let schema = SearchOverrideSchema<SearchOverrideExclude>(
            rule: SearchOverrideRule(tags: ["test"], query: "test", match: SearchOverrideRule.Match.exact, filterBy: "employees:=50"),
            includes: [SearchOverrideInclude(_id: "include-id", position: 1)],
            excludes: [SearchOverrideExclude(_id: "exclude-id")],
            filterBy: "test:=true",
            removeMatchedTokens: false,
            metadata: SearchOverrideExclude(_id: "test-json"),
            sortBy: "asc",
            replaceQuery: "test",
            filterCuratedHits: false,
            effectiveFromTs: 123,
            effectiveToTs: 456,
            stopProcessing: false
        )
        do {
            let (result, _) = try await client.collection(name: "test-utils-collection").overrides().upsert(overrideId: "test-id", params: schema)
            XCTAssertNotNil(result)
            guard let validOverride = result else {
                throw DataError.dataNotFound
            }
            print(validOverride)
            XCTAssertEqual("test-id", validOverride._id)
            XCTAssertEqual("test", validOverride.rule.query)
            XCTAssertEqual("test-json", validOverride.metadata?._id)
            XCTAssertEqual("include-id", validOverride.includes?[0]._id)
            XCTAssertEqual("exclude-id", validOverride.excludes?[0]._id)
            XCTAssertEqual("test:=true", validOverride.filterBy)
            XCTAssertEqual(false, validOverride.removeMatchedTokens)
            XCTAssertEqual("asc", validOverride.sortBy)
            XCTAssertEqual("test", validOverride.replaceQuery)
            XCTAssertEqual(false, validOverride.filterCuratedHits)
            XCTAssertEqual(123, validOverride.effectiveFromTs)
            XCTAssertEqual(456, validOverride.effectiveToTs)
            XCTAssertEqual(false, validOverride.stopProcessing)
        } catch ResponseError.requestMalformed( let desc) {
            print(desc)
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testOverridesRetrieve() async {
        try? await setUpCollection()
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))
        let client = Client(config: config)
        let _ = try! await client.collection(name: "test-utils-collection").overrides().upsert(
            overrideId: "test-id",
            params: SearchOverrideSchema<SearchOverrideExclude>(rule: SearchOverrideRule(filterBy: "test"), filterBy: "test:=true")
        )

        do {
            let (overrides, _) = try await client.collection(name: "test-utils-collection").overrides().retrieve(metadataType: SearchOverrideExclude.self )
            guard let validOverrides = overrides else {
                throw DataError.dataNotFound
            }
            print(validOverrides)
            XCTAssertEqual(1, validOverrides.overrides.count)
            XCTAssertEqual("test-id", validOverrides.overrides[0]._id)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

}
