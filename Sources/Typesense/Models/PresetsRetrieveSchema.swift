import Foundation



public struct PresetsRetrieveSchema: Codable {

    public var presets: [PresetSchema]

    public init(presets: [PresetSchema]) {
        self.presets = presets
    }


}
