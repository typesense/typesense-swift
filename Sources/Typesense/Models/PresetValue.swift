public enum PresetValue: Codable {
    case multiSearch(MultiSearchSearchesParameter)
    case singleCollectionSearch(SearchParameters)

    public init (from decoder: Decoder) throws {
        if let multiSearch = try? MultiSearchSearchesParameter(from: decoder) {
            self = .multiSearch(multiSearch)
        }
        else if let singleCollectionSearch = try? SearchParameters(from: decoder) {
            self = .singleCollectionSearch(singleCollectionSearch)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unable to decode value for preset `value`"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .multiSearch(let multiSearch):
            try multiSearch.encode(to: encoder)
        case .singleCollectionSearch(let singleCollectionSearch):
            try singleCollectionSearch.encode(to: encoder)
        }
    }
}