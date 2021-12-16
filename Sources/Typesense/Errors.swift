import Foundation

enum HTTPError: Error {
    case serverError(code: Int, desc: String)
}

enum URLError: Error {
    case invalidURL
}

enum DataError: Error {
    case unableToParse
    case dataNotFound
}

enum ResponseError: Error {
    case collectionAlreadyExists(desc: String)
    case collectionDoesNotExist(desc: String)
}
