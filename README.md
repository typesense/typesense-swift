# Typesense Swift

A great new way to implement your searches on iOS using [Typesense](https://github.com/typesense/typesense) ⚡️🔍✨ Typesense Swift is a high level wrapper that helps you easily implement searching using Typesense.

## Installation

Add `Typesense Swift` Swift Package to your project. You can refer [Apple's Documentation](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) to add Typesense Swift as a dependency to your iOS Project. You can also import Typesense into your own Swift Package by adding this line to dependencies array of `Package.swift`:

```swift
...
dependencies: [
           .package(url: "https://github.com/typesense/typesense-swift", .upToNextMajor(from: "0.2.0"),
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
let node1 = Node(host: "localhost", port: "8108", nodeProtocol: "http")
let node2 = Node(host: "super-awesome.search", port: "8080", nodeProtocol: "https") //and so on
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

let (data, response) = try await client.collections.create(schema: myCoolSchema)
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

Define your [search parameters](https://typesense.org/docs/0.22.1/api/documents.html#arguments) clearly and then perform the search operation by mentioning your Document Type:

```swift
let searchParameters = SearchParameters(q: "hog", queryBy: "school_name", filterBy: "num_students:>500", sortBy: "num_students:desc")

let (data, response) = try await client.collection(name: "schools").documents().search(searchParameters, for: School.self)
```

This returns a `SearchResult` object as the data, which can be further parsed as desired.

### Create or update an override

```swift
let schema = SearchOverrideSchema<MetadataType>(
    rule: SearchOverrideRule(tags: ["test"], query: "apple", match: SearchOverrideRule.Match.exact, filterBy: "employees:=50"),
    includes: [SearchOverrideInclude(_id: "include-id", position: 1)],
    excludes: [SearchOverrideExclude(_id: "exclude-id")],
    filterBy: "test:=true",
    removeMatchedTokens: false,
    metadata: MetadataType(message: "test-json"),
    sortBy: "num_employees:desc",
    replaceQuery: "test",
    filterCuratedHits: false,
    effectiveFromTs: 123,
    effectiveToTs: 456,
    stopProcessing: false
)
let (data, response) = try await client.collection(name: "books").overrides().upsert(overrideId: "test-id", params: schema)
```

### Retrieve all overrides

```swift
let (data, response) = try await client.collection(name: "books").overrides().retrieve(metadataType: Never.self)
```

### Retrieve an override

```swift
let (data, response) = try await client.collection(name: "books").override("test-id").retrieve(metadataType: MetadataType.self)
```

### Delete an override

```swift
let (data, response) = try await client.collection(name: "books").override("test-id").delete()
```

### Create or update a preset

```swift
let schema = PresetUpsertSchema(
    value: PresetValue.singleCollectionSearch(SearchParameters(q: "apple"))
    // or: value: PresetValue.multiSearch(MultiSearchSearchesParameter(searches: [MultiSearchCollectionParameters(q: "apple")]))
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
    case .singleCollectionSearch(let value):
        print(value)
    case .multiSearch(let value):
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

### Delete a preset

```swift
let (data, response) = try await client.stopword("stopword_set1").delete()
```

## Contributing

Issues and pull requests are welcome on GitHub at [Typesense Swift](https://github.com/typesense/typesense-swift). Do note that the Models used in the Swift client are generated by [Swagger-Codegen](https://github.com/swagger-api/swagger-codegen) and are automated to be modified in order to prevent major errors. So please do use the shell script that is provided in the repo to generate the models:

```shell
sh get-models.sh
```

The generated Models (inside the Models directory) are to be used inside the Models directory of the source code as well. Models need to be generated as and when the [Typesense-Api-Spec](https://github.com/typesense/typesense-api-spec) is updated.

## TODO: Features

- Dealing with Dirty Data
- Scoped Search Key
