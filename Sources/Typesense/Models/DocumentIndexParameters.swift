import Foundation



public struct DocumentIndexParameters: Codable {

    public var action: IndexAction?
    public var dirtyValues: DirtyValues?

    public init(action: IndexAction? = nil, dirtyValues: DirtyValues? = nil) {
        self.action = action
        self.dirtyValues = dirtyValues
    }

    public enum CodingKeys: String, CodingKey {
        case action
        case dirtyValues = "dirty_values"
    }

}