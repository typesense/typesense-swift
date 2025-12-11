# Typesense Swift

A great new way to implement your searches on iOS using [Typesense](https://github.com/typesense/typesense) ⚡️🔍✨ Typesense Swift is a high level wrapper that helps you easily implement searching using Typesense.

## Installation

Add `Typesense Swift` Swift Package to your project. You can refer [Apple's Documentation](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) to add Typesense Swift as a dependency to your iOS Project. You can also import Typesense into your own Swift Package by adding this line to dependencies array of `Package.swift`:

```swift
...
dependencies: [
           .package(url: "https://github.com/typesense/typesense-swift", .upToNextMajor(from: "1.0.0"),
],
...
```

## Usage

### Setting up the client

Import Typesense onto your Swift Project:

```swift
import Typesense
```

Declare the Typesense nodes that are available as `Node` members:

```swift
let node1 = Node(url: "http://localhost:8108") // or
let node2 = Node(host: "xxx-1.a1.typesense.net", port: "443", nodeProtocol: "https")
```

Create a configuration and hence a client with the Nodes mentioned:

```swift
let myConfig = Configuration(nodes: [node1, node2], apiKey: "coolstuff")

let client = Client(config: myConfig)
```

You can use Typesense parameters like `nearestNode` and `connectionTimeoutSeconds` while creating the configuration. You can also pass in a `logger` parameter to debug the code like this:

```swift
let myConfig = Configuration(nodes: [node1, node2], apiKey: "coolstuff", logger: Logger(debugMode: true))
```

### Indexing documents

You can create a collection by first defining a collection schema:

```swift
let myCoolSchema = CollectionSchema(name: "schools", fields: [Field(name: "school_name", type: "string"), Field(name: "num_students", type: "int32"), Field(name: "country", type: "string", facet: true)], defaultSortingField: "num_students")

let (data, response) = try await client.collections().create(schema: myCoolSchema)
```

Define the structure of your document as per your collection, and index it by inserting/upserting it to the collection:

```swift
struct School: Codable {
    var id: String
    var school_name: String
    var num_students: Int
    var country: String
}

let document = School(id: "7", school_name: "Hogwarts", num_students: 600, country: "United Kingdom")
let documentData = try JSONEncoder().encode(document)
let (data, response) = try await client.collection(name: "schools").documents().create(document: documentData)
//or
let (data, response) = try await client.collection(name: "schools").documents().upsert(document: documentData)
```

You can perform CRUD actions to `Collections` and `Documents` that belong to a certain collection. You can also use `.importBatch()` on the `documents()` method to import and index a batch of documents (in .jsonl format).

### Searching

Define your [search parameters](https://typesense.org/docs/27.0/api/search.html#search-parameters) clearly and then perform the search operation by mentioning your Document Type:

```swift
let searchParameters = SearchParameters(q: "hog", queryBy: "school_name", filterBy: "num_students:>500", sortBy: "num_students:desc")

let (data, response) = try await client.collection(name: "schools").documents().search(searchParameters, for: School.self)
```

This returns a `SearchResult` object as the data, which can be further parsed as desired.

### Bulk import documents

```swift
let jsonL = Data("{}".utf8)
let (data, response) = try await client.collection(name: "companies").documents().importBatch(jsonL, options: ImportDocumentsParameters(
        batchSize: 10,
        returnId: false,
        remoteEmbeddingBatchSize: 10,
        returnDoc: true,
        action: .upsert,
        dirtyValues: .drop
))
```

### Update multiple documents by query

```swift
let (data, response) = try await client.collection(name: "companies").documents().update(
    document: ["company_size": "large"],
    options: UpdateDocumentsParameters(filterBy: "num_employees:>1000")
)
```

### Delete multiple documents by query

```swift
let (data, response) = try await client.collection(name: "companies").documents().delete(
    options: DeleteDocumentsParameters(filterBy: "num_employees:>100")
)
```

### Export documents

```swift
let (data, response) = try await client.collection(name: "companies").documents().export(options: ExportDocumentsParameters(excludeFields: "country"))
```

### Create or update a collection alias

```swift
let schema = CollectionAliasSchema(collectionName: "companies_june")
let (data, response) = try await client.aliases().upsert(name: "companies", collection: schema)
```

### Retrieve all aliases

```swift
let (data, response) = try await client.aliases().retrieve()
```

### Retrieve an alias

```swift
let (data, response) = try await client.aliases().retrieve(name: "companies")
```

### Delete an alias

```swift
let (data, response) = try await client.aliases().delete(name: "companies")
```

### Create an API key

```swift
let adminKey = ApiKeySchema(description: "Test key with all privileges", actions: ["*"], collections: ["*"])
let (data, response) = try await client.keys().create(adminKey)
```

### Retrieve all API keys

```swift
let (data, response) = try await client.keys().retrieve()
```

### Retrieve an API key

```swift
let (data, response) = try await client.keys().retrieve(id: 1)
```

### Delete an API key

```swift
let (data, response) = try await client.keys().delete(id: 1)
```

### Create a conversation model

```swift
let schema = ConversationModelCreateSchema(
    modelName: "openai/gpt-3.5-turbo",
    historyCollection: "conversation_store",
    maxBytes: 16384,
    id: "conv-model-1",
    apiKey: "OPENAI_API_KEY",
    systemPrompt: "You are an assistant for question-answering...",
    ttl: 10000,
)
let (data, response) = try await client.conversations().models().create(params: schema)
```

### Retrieve all conversation models

```swift
let (data, response) = try await client.conversations().models().retrieve()
```

### Retrieve a conversation model

```swift
let (data, response) = try await client.conversations().model(modelId: "conv-model-1").retrieve()
```

### Update a conversation model

```swift
let (data, response) = try await client.conversations().model(modelId: "conv-model-1").update(params: ConversationModelUpdateSchema(
    systemPrompt: "..."
))
```

### Delete a conversation model

```swift
let (data, response) = try await client.conversations().model(modelId: "conv-model-1").delete()
```

### Create or update a curation set

```swift
let schema = CurationSetCreateSchema(items: [
        CurationItemCreateSchema(
            rule: CurationRule( query: "apple", match: .exact),
            includes: [
                CurationInclude(id: "422", position: 1),
                CurationInclude(id: "54", position: 2),
            ], excludes: [CurationExclude(id: "287")],
            id: "customize-apple"
        )
    ])
let (data, response) = try await client.curationSets().upsert("curate_products", schema)
```

### Retrieve all curation sets

```swift
let (data, response) = try await client.curationSets().retrieve()
```

### Retrieve a curation set

```swift
let (data, response) = try await client.curationSet("curate_products").retrieve()
```

### Delete a curation set

```swift
let (data, response) = try await client.curationSet("curate_products").delete()
```

### Retrieve all curation set items

```swift
let (data, response) = try await client.curationSet("curate_products").items().retrieve()
```

### Upsert a curation set item

```swift
let (data, response) = try await client.curationSet("curate_products").items().upsert("customize-apple-2",  CurationItemCreateSchema(
    rule: CurationRule( query: "apple", match: .exact),
    includes: [
        CurationInclude(id: "422", position: 1),
        CurationInclude(id: "54", position: 2),
    ], excludes: [CurationExclude(id: "287")],
))
```

### Retrieve a curation set item

```swift
let (data, response) = try await client.curationSet("curate_products").item("customize-apple").retrieve()
```

### Delete a curation set item

```swift
let (data, response) = try await client.curationSet("curate_products").item("customize-apple").delete()
```

### Create or update a preset

```swift
let schema = PresetUpsertSchema(
    value: PresetUpsertSchemaValue.typeSearchParameters(SearchParameters(q: "apple"))
    // or: value: PresetUpsertSchemaValue.typeMultiSearchSearchesParameter(MultiSearchSearchesParameter(searches: [MultiSearchCollectionParameters(q: "apple")]))
)
let (data, response) = try await client.presets().upsert(presetName: "listing_view", params: schema)
```

### Retrieve all presets

```swift
let (data, response) = try await client.presets().retrieve()
```

### Retrieve a preset

```swift
let (data, response) = try await client.preset("listing_view").retrieve()

switch data?.value {
    case .typeSearchParameters(let value):
        print(value)
    case .typeMultiSearchSearchesParameter(let value):
        print(value)
}
```

### Delete a preset

```swift
let (data, response) = try await client.preset("listing_view").delete()
```

### Create or update a stopwords set

```swift
let schema = StopwordsSetUpsertSchema(
    stopwords: ["states","united"],
    locale: "en"
)
let (data, response) = try await client.stopwords().upsert(stopwordsSetId: "stopword_set1", params: schema)
```

### Retrieve all stopwords sets

```swift
let (data, response) = try await client.stopwords().retrieve()
```

### Retrieve a stopwords set

```swift
let (data, response) = try await client.stopword("stopword_set1").retrieve()
```

### Delete a stopwords set

```swift
let (data, response) = try await client.stopword("stopword_set1").delete()
```

### Create or update a synonym

```swift
let schema = SearchSynonymSchema(synonyms: ["blazer", "coat", "jacket"])
let (data, response) = try await client.collection(name: "products").synonyms().upsert(id: "coat-synonyms", schema)
```

### Retrieve all synonyms

```swift
let (data, response) = try await client.collection(name: "products").synonyms().retrieve()
```

### Retrieve a synonym

```swift
let (data, response) = try await client.collection(name: "products").synonyms().retrieve(id: "coat-synonyms")
```

### Delete a synonym

```swift
let (data, response) = try await myClient.collection(name: "products").synonyms().delete(id: "coat-synonyms")
```

### Retrieve debug information

```swift
let (data, response) = try await client.operations().getDebug()
```

### Retrieve health status

```swift
let (data, response) = try await client.operations().getHealth()
```

### Retrieve API stats

```swift
let (data, response) = try await client.operations().getStats()
```

### Retrieve Cluster Metrics

```swift
let (data, response) = try await client.operations().getMetrics()
```

### Re-elect Leader

```swift
let (data, response) = try await client.operations().vote()
```

### Toggle Slow Request Log

```swift
let (data, response) = try await client.operations().toggleSlowRequestLog(seconds: 2)
```

### Clear cache

```swift
let (data, response) = try await client.operations().clearCache()
```

### Create Snapshot (for backups)

```swift
let (data, response) = try await client.operations().snapshot(path: "/tmp/typesense-data-snapshot")
```

## Contributing

Issues and pull requests are welcome on GitHub at [Typesense Swift](https://github.com/typesense/typesense-swift). Do note that the Models used in the Swift client are generated by [OpenAPI Generator](https://github.com/OpenAPITools/openapi-generator).

When updating or adding new parameters and endpoints, make changes directly in the [Typesense API spec repository](https://github.com/typesense/typesense-api-spec).

Once your changes are merged, you can update this project as follows:

```bash
swift run Tasks fetch
swift run Tasks preprocess
swift run Tasks code-gen
```

This will:

- Download the latest API spec.
- Write it to our local [`openapi.yml`](./openapi.yml).
- Preprocess it into [`preprocessed_openapi.yml`](./preprocessed_openapi.yml).
- Generate and replace the `Sources/Typesense/Models` folder.

The preprocessing step does two things:

- Flatten the URL params defined as objects into individual URL parameters (in [`PreprocessOpenAPI.swift`](Tasks/PreprocessOpenAPI.swift))
- Inject OpenAPI vendor attributes `x-swift-*` (e.g., generic parameters, schema builders) into the spec before code generation (in [`AddVendorAttributes.swift`](Tasks/AddVendorAttributes.swift))

## TODO: Features

- Scoped Search Key
