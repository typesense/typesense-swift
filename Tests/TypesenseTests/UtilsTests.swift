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