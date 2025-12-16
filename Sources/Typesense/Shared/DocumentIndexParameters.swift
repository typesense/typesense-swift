public struct DocumentIndexParameters: Codable {

    public var dirtyValues: DirtyValues?

    public init(dirtyValues: DirtyValues? = nil) {
        self.dirtyValues = dirtyValues
    }

    public enum CodingKeys: String, CodingKey {
        case dirtyValues = "dirty_values"
    }

}