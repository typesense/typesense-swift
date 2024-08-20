import Foundation



public struct DebugRetrieveSchema: Codable {

    public var state: Int
    public var version: String

    public init(state: Int, version: String) {
        self.state = state
        self.version = version
    }


}
