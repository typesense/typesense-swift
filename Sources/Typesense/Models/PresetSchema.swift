import Foundation



public struct PresetSchema: Codable {
    public var name: String
    public var value: PresetValue

    public init(name: String, value: PresetValue) {
        self.name = name
        self.value = value
    }


}
