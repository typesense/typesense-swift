import Foundation



public struct PresetUpsertSchema: Codable {

    public var value: PresetValue

    public init(value: PresetValue) {
        self.value = value
    }


}
