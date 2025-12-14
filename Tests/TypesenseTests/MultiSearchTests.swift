import XCTest
@testable import Typesense

final class MultiSearchTests: XCTestCase {
    override func setUp() async throws {
        let productSchema = CollectionSchema(name: "products", fields: [
            Field(name: "name", type: "string"),
            Field(name: "price", type: "int32"),
            Field(name: "brand", type: "string"),
            Field(name: "desc", type: "string"),
        ])
        let brandSchema = CollectionSchema(name: "brands", fields: [
            Field(name: "name", type: "string"),
        ])


        let _ = try await client.collections.create(schema: productSchema)
        let _ = try await client.collections.create(schema: brandSchema)
    }

    override func tearDown() async throws {
       try await tearDownCollections()
    }

    struct Brand: Codable, Equatable {
        var name: String
    }

    enum ProductOrBrand: Codable {
        case brand(Brand)
        case product(Product)

        // Define keys to look for the discriminator
        enum CodingKeys: String, CodingKey {
            case type // Assuming your JSON has a field distinguishing the data
        }

        public func encode(to encoder: Encoder) throws {}

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(Product.self) {
                self = .product(value)
            } else if let value = try? container.decode(Brand.self) {
                self = .brand(value)
            } else {
                throw DecodingError.typeMismatch(Self.Type.self, .init(codingPath: decoder.codingPath, debugDescription: "Unable to decode instance of ProductOrBrand"))
            }
        }
    }


    func testMultiSearch() async {
        let searchRequests = [
            MultiSearchCollectionParameters(q: "Jor", filterBy: "price:=[50..120]", collection: "products"),
            MultiSearchCollectionParameters(q: "Nike", collection: "brands"),
        ]

        let brand1 = Brand(name: "Nike")
        let product1 = Product(name: "Jordan", price: 70, brand: "Nike", desc: "High quality shoe")

        let commonParams = MultiSearchParameters(queryBy: "name")

        do {

            let (_,_) = try await client.collection(name: "products").documents().create(document: encoder.encode(product1))

            let (_,_) = try await client.collection(name: "brands").documents().create(document: encoder.encode(brand1))

            let (data, _) = try await client.multiSearch().perform(searchRequests: searchRequests, commonParameters: commonParams, for: ProductOrBrand.self)


            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }

            XCTAssertNotNil(validResp.results)
            XCTAssertNotEqual(validResp.results.count, 0)
            XCTAssertNotNil(validResp.results[0].hits)
            XCTAssertNotNil(validResp.results[1].hits)
            XCTAssertEqual(validResp.results[1].hits?.count, 1)

            if case let .product(product) = validResp.results[0].hits![0].document {
                XCTAssertEqual(product.name, product1.name)
            }else{
                XCTAssertTrue(false)
            }

            if case let .brand(brand) = validResp.results[1].hits![0].document {
                XCTAssertEqual(brand.name, brand1.name)
            }else{
                XCTAssertTrue(false)
            }

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

    func testMultiSearchReturnRawData() async {

        let searchRequests = [
            MultiSearchCollectionParameters(q: "shoe", filterBy: "price:=[50..120]", collection: "products"),
            MultiSearchCollectionParameters(q: "Nike", collection: "brands"),
        ]

        let brand1 = Brand(name: "Nike")
        let product1 = Product(name: "Jordan", price: 70, brand: "Nike", desc: "High quality shoe")

        let commonParams = MultiSearchParameters(queryBy: "name")

        do {
            let (_,_) = try await client.collection(name: "products").documents().create(document: encoder.encode(product1))

            let (_,_) = try await client.collection(name: "brands").documents().create(document: encoder.encode(brand1))

            let (data, _) = try await client.multiSearch().perform(searchRequests: searchRequests, commonParameters: commonParams)

            guard let validData = data else {
                throw DataError.dataNotFound
            }
             if let json = try JSONSerialization.jsonObject(with: validData, options: []) as? [String: Array<[String: Any]>]{
                print(json)
                XCTAssertNotNil(json["results"]?[0])
                XCTAssertNotNil(json["results"]?[1])
             } else{
                XCTAssertTrue(false)
             }
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

        let preset = PresetUpsertSchema(
            value: .typeMultiSearchSearchesParameter(MultiSearchSearchesParameter(
                searches:[
                    MultiSearchCollectionParameters(q: "shoe", filterBy: "price:=[50..120]", collection: "products"),
                    MultiSearchCollectionParameters(q: "Nike", collection: "brands"),
                    ]
            ))
        )


        let brand1 = Brand(name: "Nike")
        let product1 = Product(name: "Jordan", price: 70, brand: "Nike", desc: "High quality shoe")

        let commonParams = MultiSearchParameters(queryBy: "name", preset: "test-multi-search")

        do {
            let _ = try await client.presets().upsert(presetName: "test-multi-search", params: preset)

            let (_,_) = try await client.collection(name: "products").documents().create(document: encoder.encode(product1))

            let (_,_) = try await client.collection(name: "brands").documents().create(document: encoder.encode(brand1))

            let (data, _) = try await client.multiSearch().perform(searchRequests: [], commonParameters: commonParams, for: ProductOrBrand.self)


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
            print(error)
            XCTAssertTrue(false)
        }
        try? await tearDownPresets()
    }


    func testMultiSearchUnionReturnRawData() async {
        let searchRequests = [
            MultiSearchCollectionParameters(q: "shoe", filterBy: "price:=[50..120]", collection: "products"),
            MultiSearchCollectionParameters(q: "Nike", collection: "brands"),
        ]

        let brand1 = Brand(name: "Nike")
        let product1 = Product(name: "Jordan", price: 70, brand: "Nike", desc: "High quality shoe")

        let commonParams = MultiSearchParameters(queryBy: "name")

        do {
            let (_,_) = try await client.collection(name: "products").documents().create(document: encoder.encode(product1))

            let (_,_) = try await client.collection(name: "brands").documents().create(document: encoder.encode(brand1))

            let (data, _) = try await client.multiSearch().performUnion(searchRequests: searchRequests, commonParameters: commonParams)

            guard let validData = data else {
                throw DataError.dataNotFound
            }
             if let json = try JSONSerialization.jsonObject(with: validData, options: []) as? [String: Any]{
                print(json)
                XCTAssertNotNil(json["hits"])
             } else{
                XCTAssertTrue(false)
             }
        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }

    }

    func testMultiSearchUnion() async {
        let searchRequests = [
            MultiSearchCollectionParameters(q: "shoe", filterBy: "price:=[50..120]", collection: "products"),
            MultiSearchCollectionParameters(q: "Nike", collection: "brands"),
        ]

        let brand1 = Brand(name: "Nike")
        let product1 = Product(name: "Jordan", price: 70, brand: "Nike", desc: "High quality shoe")

        let commonParams = MultiSearchParameters(queryBy: "name")

        do {

            let (_,_) = try await client.collection(name: "products").documents().create(document: encoder.encode(product1))

            let (_,_) = try await client.collection(name: "brands").documents().create(document: encoder.encode(brand1))

            let (data, _) = try await client.multiSearch().performUnion(searchRequests: searchRequests, commonParameters: commonParams, for: ProductOrBrand.self)


            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }

            XCTAssertNotNil(validResp.hits)
            XCTAssertNotEqual(validResp.hits!.count, 0)
            if case let .product(product) = validResp.hits![0].document {
                XCTAssertEqual(product.name, product1.name)
            } else if case let .brand(brand) = validResp.hits![0].document {
                XCTAssertEqual(brand.name, brand1.name)
            }

        } catch HTTPError.serverError(let code, let desc) {
            print(desc)
            print("The response status code is \(code)")
            XCTAssertTrue(false)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }

    }

    func testMultiSearchPack() async {
        let searchRequests = [
            MultiSearchCollectionParameters(q: "Jor", filterBy: "price:=[50..120]", collection: "products"),
            MultiSearchCollectionParameters(q: "Nike", collection: "brands"),
        ]

        let brand1 = Brand(name: "Nike")
        let product1 = Product(name: "Jordan", price: 70, brand: "Nike", desc: "High quality shoe")

        let commonParams = MultiSearchParameters(queryBy: "name")

        do {

            let (_,_) = try await client.collection(name: "products").documents().create(document: encoder.encode(product1))

            let (_,_) = try await client.collection(name: "brands").documents().create(document: encoder.encode(brand1))

            let (data, _) = try await client.multiSearch().perform(searchRequests: searchRequests, commonParameters: commonParams, for: (Product.self, Brand.self))


            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }

            XCTAssertEqual(validResp.results.0.hits?[0].document, product1)
            XCTAssertEqual(validResp.results.1.hits?[0].document, brand1)
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
