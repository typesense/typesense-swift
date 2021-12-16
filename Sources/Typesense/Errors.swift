import Foundation

public enum HTTPError: Error {
    case serverError(code: Int, desc: String)
}

public enum URLError: Error {
    case invalidURL
}

public enum DataError: Error {
    case unableToParse
    case dataNotFound
}

public enum ResponseError: Error {
    case collectionAlreadyExists(desc: String)
    case collectionDoesNotExist(desc: String)
}
