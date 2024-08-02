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
    case documentAlreadyExists(desc: String)
    case documentDoesNotExist(desc: String)
    case invalidCollection(desc: String)
    case apiKeyNotFound(desc: String)
    case aliasNotFound(desc: String)
    case analyticsRuleDoesNotExist(desc: String)
    case requestMalformed(desc: String)
}
