import XCTest
@testable import Typesense

final class MultiSearchTests: XCTestCase {
    override func tearDown() async throws {
        try! await tearDownCollections()
    }

    struct Brand: Codable {
        var name: String
    }


    func testMultiSearch() async {
        let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz", logger: Logger(debugMode: true))

        let client = Client(config: config)

        let productSchema = CollectionSchema(name: "products", fields: [
            Field(name: "name", type: "string"),
            Field(name: "price", type: "int32"),
            Field(name: "brand", type: "string"),
            Field(name: "desc", type: "string"),
        ])

        let brandSchema = CollectionSchema(name: "brands", fields: [
            Field(name: "name", type: "string"),
        ])

        let searchRequests = [
            MultiSearchCollectionParameters(q: "shoe", filterBy: "price:=[50..120]", collection: "products"),
            MultiSearchCollectionParameters(q: "Nike", collection: "brands"),
        ]

        let brand1 = Brand(name: "Nike")
        let product1 = Product(name: "Jordan", price: 70, brand: "Nike", desc: "High quality shoe")

        let commonParams = MultiSearchParameters(queryBy: "name")

        do {
            do {
                let _ = try await client.collections.create(schema: productSchema)
            } catch ResponseError.collectionAlreadyExists(let desc) {
                print(desc)
            } catch (let error) {
                print(error.localizedDescription)
                XCTAssertTrue(false)
            }

            do {
                let _ = try await client.collections.create(schema: brandSchema)
            } catch ResponseError.collectionAlreadyExists(let desc) {
                print(desc)
            } catch (let error) {
                print(error.localizedDescription)
                XCTAssertTrue(false)
            }

            let (_,_) = try await client.collection(name: "products").documents().create(document: encoder.encode(product1))

            let (_,_) = try await client.collection(name: "brands").documents().create(document: encoder.encode(brand1))

            let (data, _) = try await client.multiSearch().perform(searchRequests: searchRequests, commonParameters: commonParams, for: Product.self)


            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }

            XCTAssertNotNil(validResp.results)
            XCTAssertNotEqual(validResp.results.count, 0)
            XCTAssertNotNil(validResp.results[0].hits)
            XCTAssertNotNil(validResp.results[1].hits)
            XCTAssertEqual(validResp.results[1].hits?.count, 1)

            print(validResp.results[1].hits as Any)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }

    }

    func testMultiSearchWithPreset() async {
        let productSchema = CollectionSchema(name: "products", fields: [
            Field(name: "name", type: "string"),
            Field(name: "price", type: "int32"),
            Field(name: "brand", type: "string"),
            Field(name: "desc", type: "string"),
        ])

        let brandSchema = CollectionSchema(name: "brands", fields: [
            Field(name: "name", type: "string"),
        ])

        let preset = PresetUpsertSchema(
            value: .multiSearch(MultiSearchSearchesParameter(
                searches:[
                    MultiSearchCollectionParameters(q: "shoe", filterBy: "price:=[50..120]", collection: "products"),
                    MultiSearchCollectionParameters(q: "Nike", collection: "brands"),
                    ]
            ))
        )

        let _ = try! await client.presets().upsert(presetName: "test-multi-search", params: preset)

        let brand1 = Brand(name: "Nike")
        let product1 = Product(name: "Jordan", price: 70, brand: "Nike", desc: "High quality shoe")

        let commonParams = MultiSearchParameters(queryBy: "name", preset: "test-multi-search")

        do {
            do {
                let _ = try await client.collections.create(schema: productSchema)
            } catch ResponseError.collectionAlreadyExists(let desc) {
                print(desc)
            } catch (let error) {
                print(error.localizedDescription)
                XCTAssertTrue(false)
            }

            do {
                let _ = try await client.collections.create(schema: brandSchema)
            } catch ResponseError.collectionAlreadyExists(let desc) {
                print(desc)
            } catch (let error) {
                print(error.localizedDescription)
                XCTAssertTrue(false)
            }

            let (_,_) = try await client.collection(name: "products").documents().create(document: encoder.encode(product1))

            let (_,_) = try await client.collection(name: "brands").documents().create(document: encoder.encode(brand1))

            let (data, _) = try await client.multiSearch().perform(searchRequests: [], commonParameters: commonParams, for: Product.self)


            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }

            XCTAssertNotNil(validResp.results)
            XCTAssertNotEqual(validResp.results.count, 0)
            XCTAssertNotNil(validResp.results[0].hits)
            XCTAssertNotNil(validResp.results[1].hits)
            XCTAssertEqual(validResp.results[1].hits?.count, 1)

            print(validResp.results[1].hits as Any)
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
        try! await tearDownPresets()
    }



}
