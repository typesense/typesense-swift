import Foundation

enum HTTPError: Error {
    case serverError(code: Int, desc: String)
}

enum URLError: Error {
    case invalidURL
}
