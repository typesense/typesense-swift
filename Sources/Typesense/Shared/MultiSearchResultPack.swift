import Foundation


public enum MultiSearchResultPackCodingKeys: String, CodingKey {
    case conversation
    case results
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct MultiSearchResultPack<each T: Codable>: Codable {

    public var conversation: SearchResultConversation?
    public var results: (repeat MultiSearchResultItem<each T>)

    public init(results: (repeat MultiSearchResultItem<each T>), conversation: SearchResultConversation? = nil) {
        self.conversation = conversation
        self.results = results
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MultiSearchResultPackCodingKeys.self)
        self.conversation = try container.decodeIfPresent(SearchResultConversation.self, forKey: .conversation)

        var resultsContainer = try container.nestedUnkeyedContainer(forKey: .results)

        self.results = (repeat try resultsContainer.decode(MultiSearchResultItem<each T>.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MultiSearchResultPackCodingKeys.self)
        try container.encodeIfPresent(conversation, forKey: .conversation)

        var resultsContainer = container.nestedUnkeyedContainer(forKey: .results)

        let mirror = Mirror(reflecting: results)
        for child in mirror.children {
            guard let value = child.value as? Encodable else {
                continue
            }

            let superEncoder = resultsContainer.superEncoder()
            try value.encode(to: superEncoder)
        }
    }
}
