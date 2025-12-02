import XCTest
@testable import Typesense

final class ConversationModelTests: XCTestCase {
    func testConversationModelsCreate() async {
        let schema = ConversationModelCreateSchema(
            historyCollection: "conversation_store",
            maxBytes: 16384,
            modelName: "test/gpt-3.5-turbo",
            apiKey: "sk",
            id: "conv-model-1",
            systemPrompt: "You are an assistant for question-answering.",
            ttl: 123,
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

    func testConversationSearch() async {
        do {
            let string = """
            {
            "conversation": {
                "answer": " context information, I' unable to suggest an is information given about specific context action as,, specific titles If a preference for particular genre length of, please that information and I' try my best to suggestions.",
                "conversation_history": [
                {
                    "user": "can you suggest an action series"
                },
                {
                    "assistant": " context information, I' unable to suggest an is information given about specific context action as,, specific titles If a preference for particular genre length of, please that information and I' try my best to suggestions."
                }
                ],
                "conversation_id": "123",
                "query": "can you suggest an action series"
            },
            "results": [
                {
                "code": 404,
                "error": "Not found."
                }
            ]
            }
            """
            let data = string.data(using: .utf8)!
            let _ = try decoder.decode(MultiSearchResult<Never>.self, from: data)
            XCTAssertTrue(true)
        }catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

}
