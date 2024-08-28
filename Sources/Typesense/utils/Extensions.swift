import Foundation

private let urlAllowed: CharacterSet = .alphanumerics.union(.init(charactersIn: "-._~"))

internal extension String {
    func encodeURL() throws -> String {
        let percentEncoded = self.addingPercentEncoding(withAllowedCharacters: urlAllowed)
        guard let valid = percentEncoded else{
            throw URLError.encodingError(message: "Failed to encode URL for string `\(self)`")
        }
        return valid
    }
}