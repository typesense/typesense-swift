import Foundation



public struct AnalyticsEventCreateSchema<T: Encodable>: Encodable {

    public var type: String
    public var name: String
    public var data: T

    public init(type: String, name: String, data: T) {
        self.type = type
        self.name = name
        self.data = data
    }


}
