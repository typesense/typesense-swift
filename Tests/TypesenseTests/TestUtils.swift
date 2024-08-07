import Typesense

let config = Configuration(nodes: [Node(host: "localhost", port: "8108", nodeProtocol: "http")], apiKey: "xyz")
let client = Client(config: config)

func tearDownCollections() async throws {
    let (collResp, _) = try await client.collections.retrieveAll()
    guard let validData = collResp else {
        throw DataError.dataNotFound
    }
    for item in validData {
        let _ = try! await client.collection(name: item.name).delete()
    }
}

func tearDownPresets() async throws {
    let (presets, _) = try await client.presets().retrieve()
    guard let validData = presets else {
        throw DataError.dataNotFound
    }
    for item in validData.presets {
        let _ = try! await client.preset(item.name).delete()
    }
}

func tearDownStopwords() async throws {
    let (data, _) = try await client.stopwords().retrieve()
    guard let validData = data else {
        throw DataError.dataNotFound
    }
    for item in validData {
        let _ = try! await client.stopword(item._id).delete()
    }
}

func setUpCollection() async throws{
    let schema = CollectionSchema(name: "test-utils-collection", fields: [Field(name: "company_name", type: "string"), Field(name: "num_employees", type: "int32"), Field(name: "country", type: "string", facet: true)], defaultSortingField: "num_employees")
    let (collResp, _) = try! await client.collections.create(schema: schema)
    guard collResp != nil else {
        throw DataError.dataNotFound
    }
}

func createAnOverride() async throws {
    let _ = try! await client.collection(name: "test-utils-collection").overrides().upsert(
        overrideId: "test-id",
        params: SearchOverrideSchema<SearchOverrideExclude>(rule: SearchOverrideRule(filterBy: "test"), filterBy: "test:=true", metadata: SearchOverrideExclude(_id: "exclude-id"))
    )
}

func createSingleCollectionSearchPreset() async throws {
    let _ = try! await client.presets().upsert(
        presetName: "test-id",
        params: PresetUpsertSchema(
            value: .singleCollectionSearch(SearchParameters(q: "apple"))
        )
    )
}

func createMultiSearchPreset() async throws {
    let _ = try! await client.presets().upsert(
        presetName: "test-id-preset-multi-search",
        params: PresetUpsertSchema(
            value: .multiSearch(MultiSearchSearchesParameter(searches: [MultiSearchCollectionParameters(q: "banana")]))
        )
    )
}

func createStopwordSet() async throws {
    let _ = try! await client.stopwords().upsert(
        stopwordsSetId: "test-id-stopword-set",
        params: StopwordsSetUpsertSchema(
            stopwords: ["states","united"],
            locale: "en"
        )
    )
}

struct Product: Codable, Equatable {
    var name: String?
    var price: Int?
    var brand: String?
    var desc: String?

    static func == (lhs: Product, rhs: Product) -> Bool {
            return
                lhs.name == rhs.name &&
                lhs.price == rhs.price &&
                lhs.brand == rhs.brand &&
                lhs.desc == rhs.desc
    }
}