import XCTest
@testable import Typesense

final class ConversationModelTests: XCTestCase {
    func testConversationModelsCreate() async {
        let schema = ConversationModelCreateSchema(
            _id: "conv-model-1",
            modelName: "test/gpt-3.5-turbo",
            apiKey: "sk",
            historyCollection: "conversation_store",
            systemPrompt: "You are an assistant for question-answering.",
            ttl: 123,
            maxBytes: 16384
        )
        do {
            try await createConversationCollection()
            let _ = try await client.conversations().models().create(params: schema)
        } catch HTTPError.clientError(let code, let desc){
            print(desc)
            XCTAssertEqual(code, 400)
            XCTAssertTrue(desc.contains("Model namespace `test` is not supported."))
        } catch (let error) {
            print(error.localizedDescription)
            XCTAssertTrue(false)
        }
        try? await tearDownCollections()
    }

    func testConversationModelsRetrieve() async {
        do {
            let (data, _) = try await client.conversations().models().retrieve()
            guard let validData = data else {
                throw DataError.dataNotFound
            }
            XCTAssertEqual(0, validData.count)
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testConversationModelUpdate() async {
        do {
            let _ = try await client.conversations().model(modelId: "conv-model-1").update(params: ConversationModelUpdateSchema())
        } catch HTTPError.clientError(let code, let desc){
            print(desc)
            XCTAssertEqual(code, 404)
            XCTAssertTrue(desc.contains("Model not found"))
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testConversationModelRetrieve() async {
        do {
            let _ = try await client.conversations().model(modelId: "conv-model-1").retrieve()
        } catch HTTPError.clientError(let code, let desc){
            print(desc)
            XCTAssertEqual(code, 404)
            XCTAssertTrue(desc.contains("Model not found"))
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testConversationModelDelete() async {
        do {
            let _ = try await client.conversations().model(modelId: "conv-model-1").delete()
        } catch HTTPError.clientError(let code, let desc){
            print(desc)
            XCTAssertEqual(code, 404)
            XCTAssertTrue(desc.contains("Model not found"))
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

}
