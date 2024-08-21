import XCTest
@testable import Typesense

final class DocumentTests: XCTestCase {
    override func setUp() async throws {
        try! await createCollection()
    }

    override func tearDown() async throws {
        try! await tearDownCollections()
    }

    //Partial data format to be used in update() method
    struct PartialCompany: Codable {
        var id: String?
        var company_name: String?
        var num_employees: Int?
        var country: String?
    }

    func testDocumentCreate() async {
        let document = Company(id: "125", company_name: "Stark Industries", num_employees: 5215, country: "USA")

        do {
            let docuData = try encoder.encode(document)
            let (data, _) = try await client.collection(name: "companies").documents().create(document: docuData)
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            let docuResp = try decoder.decode(Company.self, from: validResp)
            XCTAssertEqual(docuResp.company_name, "Stark Industries")
            XCTAssertEqual(docuResp.num_employees, 5215)
            XCTAssertEqual(docuResp.id, "125")
            XCTAssertEqual(docuResp.country, "USA")
            print(docuResp)

        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testDocumentUpsert() async {
        let document = Company(id: "124", company_name: "Stark Industries", num_employees: 5215, country: "USA")

        do {
            let docuData = try encoder.encode(document)
            print(String(data: docuData, encoding: .utf8)!)
            let (data, _) = try await client.collection(name: "companies").documents().upsert(document: docuData)
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            let docuResp = try decoder.decode(Company.self, from: validResp)
            XCTAssertEqual(docuResp.company_name, "Stark Industries")
            XCTAssertEqual(docuResp.num_employees, 5215)
            XCTAssertEqual(docuResp.id, "124")
            XCTAssertEqual(docuResp.country, "USA")
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testDocumentDelete() async {
        do {
            try await createDocument()
            let (data, _) = try await client.collection(name: "companies").document(id: "test-id").delete()
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }

            let docuResp = try decoder.decode(Company.self, from: validResp)
            XCTAssertEqual(docuResp.company_name, "Stark Industries")
            let emps = [5215, 5500]
            XCTAssertTrue(emps.contains(docuResp.num_employees))
            XCTAssertEqual(docuResp.id, "test-id")
            XCTAssertEqual(docuResp.country, "USA")
            print(docuResp)

        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testDocumentRetrieve() async {
        do {
            try await createDocument()
            let (data, _) = try await client.collection(name: "companies").document(id: "test-id").retrieve()
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }

            let docuResp = try decoder.decode(Company.self, from: validResp)
            XCTAssertEqual(docuResp.company_name, "Stark Industries")
            let emps = [5215, 5500]
            XCTAssertTrue(emps.contains(docuResp.num_employees))
            XCTAssertEqual(docuResp.id, "test-id")
            XCTAssertEqual(docuResp.country, "USA")
            print(docuResp)

        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testDocumentUpdate() async {
        let newDoc = PartialCompany(company_name: "Stark Industries", num_employees: 5500)

        do {
            try await createDocument()
            let docuData = try encoder.encode(newDoc)
            let (data, _) = try await client.collection(name: "companies").document(id: "test-id").update(newDocument: docuData)
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }

            let docuResp = try decoder.decode(Company.self, from: validResp)
            XCTAssertEqual(docuResp.company_name, "Stark Industries")
            XCTAssertEqual(docuResp.num_employees, 5500)
            XCTAssertEqual(docuResp.id, "test-id")
            XCTAssertEqual(docuResp.country, "USA")
            print(docuResp)

        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testDocumentSearch() async {
        let searchParams = SearchParameters(q: "stark", queryBy: "company_name", filterBy: "num_employees:>100", sortBy: "num_employees:desc")

        do {
            try await createDocument()
            let (data, _) = try await client.collection(name: "companies").documents().search(searchParams, for: Company.self)
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            if let gotSomeHits = validResp.hits {
                XCTAssertNotNil(validResp.hits)
                XCTAssertNotNil(validResp.found)
                XCTAssertNotNil(gotSomeHits[0].textMatch)
                XCTAssertNotNil(gotSomeHits[0].document)
                XCTAssertNotNil(gotSomeHits[0].highlights?[0].matchedTokens)
            }
            print(validResp)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }

    }

    func testDocumentSearchWithPreset() async {
        let productSchema = CollectionSchema(name: "products", fields: [
            Field(name: "name", type: "string"),
            Field(name: "price", type: "int32"),
            Field(name: "brand", type: "string"),
            Field(name: "desc", type: "string"),
        ])

        let preset = PresetUpsertSchema(
            value: .singleCollectionSearch(
                SearchParameters(q: "Jor", queryBy: "name", filterBy: "price:=[50..120]")
            )
        )

        let _ = try! await client.presets().upsert(presetName: "single-collection-search-preset", params: preset)

        let product1 = Product(name: "Jordan", price: 70, brand: "Nike", desc: "High quality shoe")

        do {
            do {
                let _ = try await client.collections.create(schema: productSchema)
            } catch (let error) {
                print(error.localizedDescription)
                XCTAssertTrue(false)
            }

            let (_,_) = try await client.collection(name: "products").documents().create(document: encoder.encode(product1))

            let (data, _) = try await client.collection(name: "products").documents().search(SearchParameters(preset: "single-collection-search-preset"), for: Product.self)


            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }

            XCTAssertNotNil(validResp.hits)
            XCTAssertEqual(validResp.hits?.count, 1)

            print(validResp.hits as Any)
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
        try! await tearDownPresets()
    }

    func testDocumentGroupSearch() async {
        let searchParams = SearchParameters(q: "*", queryBy: "company_name", groupBy: "num_employees,country,metadata")

        do {
            try await createDocument()
            let (data, _) =  try await client.collection(name: "companies").documents().search(searchParams, for: Company.self)
            XCTAssertNotNil(data)
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            print(validData)
            if let gotSomeGroupedHits = validData.groupedHits {
                XCTAssertEqual(gotSomeGroupedHits.first?.groupKey[0].value as! Int, 5215)
                XCTAssertEqual(gotSomeGroupedHits.first?.groupKey[1].value as! String, "USA")
                XCTAssertEqual(gotSomeGroupedHits.first?.groupKey[2].value as! Bool, false)
                XCTAssertNotNil(validData.groupedHits)
                XCTAssertNotNil(validData.found)
                XCTAssertNotNil(gotSomeGroupedHits.first)
                XCTAssertNotNil(gotSomeGroupedHits.first?.found)
            }
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testDocumentImport() async {
        let documents = [
            Company(id: "124", company_name: "Stark Industries", num_employees: 5125, country: "USA"),
            Company(id: "125", company_name: "Acme Corp", num_employees: 2133, country: "CA")
        ]

        do {

            var jsonLStrings:[String] = []
            for doc in documents {
                let data = try encoder.encode(doc)
                let str = String(data: data, encoding: .utf8)!
                jsonLStrings.append(str)
            }

            let jsonLString = jsonLStrings.joined(separator: "\n")
            print(jsonLString)
            let jsonL = Data(jsonLString.utf8)

            let (data, _) = try await client.collection(name: "companies").documents().importBatch(jsonL)
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            print(String(data: validResp, encoding: .utf8) ?? "Unable to Parse JSONL")
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testDocumentImportWithOptions() async {
        let documents = [
            Company(id: "124", company_name: "Stark Industries", num_employees: 5125, country: "USA"),
            Company(id: "125", company_name: "Acme Corp", num_employees: 2133, country: "CA")
        ]

        do {
            var jsonLStrings:[String] = []
            for doc in documents {
                let data = try encoder.encode(doc)
                let str = String(data: data, encoding: .utf8)!
                jsonLStrings.append(str)
            }

            let jsonLString = jsonLStrings.joined(separator: "\n")
            print(jsonLString)
            let jsonL = Data(jsonLString.utf8)

            let (data, _) = try await client.collection(name: "companies").documents().importBatch(jsonL, options: ImportDocumentsParameters(
                action: .upsert, batchSize: 10, dirtyValues: .drop, remoteEmbeddingBatchSize: 10, returnDoc: true, returnId: false
            ))
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            print(String(data: validResp, encoding: .utf8) ?? "Unable to Parse JSONL")
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testDocumentExport() async {
        do {
            let (data, _) = try await client.collection(name: "companies").documents().export(options: ExportDocumentsParameters(excludeFields: "country"))
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            print(String(data: validResp, encoding: .utf8) ?? "Unable to Parse JSONL")
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }

    func testDocumentDeleteByQuery() async {
        do {
            let (data, _) = try await client.collection(name: "companies").documents().delete(filter: "num_employees:>100", batchSize: 100)
            XCTAssertNotNil(data)
            guard let validResp = data else {
                throw DataError.dataNotFound
            }
            print(String(data: validResp, encoding: .utf8) ?? "Unable to Parse JSON")
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
    }


}
