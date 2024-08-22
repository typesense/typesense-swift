import Foundation



public struct DeleteDocumentsResponse: Codable {

    public var numDeleted: Int

    public init(numDeleted: Int) {
        self.numDeleted = numDeleted
    }

    public enum CodingKeys: String, CodingKey {
        case numDeleted = "num_deleted"
    }

}
