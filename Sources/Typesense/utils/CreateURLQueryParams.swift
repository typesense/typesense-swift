import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

func createURLQuery<T: Codable>(forSchema: T?) throws -> [URLQueryItem]{
    var searchQueryParams: [URLQueryItem] = []

    guard let schema = forSchema else{
        return searchQueryParams
    }

    let jsonData = try encoder.encode(schema)
    let json = try JSONSerialization.jsonObject(with: jsonData, options: [])

    guard let dictionary = json as? [String : Any] else {
        throw DataError.unableToParse(message: "Unable to create query params for \(type(of: schema))")
     }

    for (key, val) in dictionary {
        var stringVal = ""
        if let str = val as? String {
            stringVal = str
        } else if type(of: val) == type(of: NSNumber(booleanLiteral: true)) || type(of: val) == type(of: NSNumber(booleanLiteral: false)), let bool = val as? Bool{
            stringVal = String(bool)
        } else if let int = val as? Int {
            stringVal = String(int)
        } else if let double = val as? Double {
            stringVal = String(double)
        } else{
            throw DataError.unableToParse(message: "Unknown data type for key: `\(key)`, type: `\(type(of: val))` of `\(type(of: schema))`")
        }
        searchQueryParams.append(URLQueryItem(name: key, value: stringVal))
    }
    return searchQueryParams
}