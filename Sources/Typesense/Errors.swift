import Foundation

public enum HTTPError: Error {
    case serverError(code: Int, desc: String)
    case clientError(code: Int, desc: String)
}

extension HTTPError: LocalizedError {
    public var errorDescription: String? {
        func errorMessage(_ code: Int, _ desc: String) -> String{
            return NSLocalizedString("Request to server failed with code \(code). Message: \(desc)", comment: "Typesense error")
        }
        switch self {
            case .serverError(let code, let desc):
                return errorMessage(code, desc)
            case .clientError(let code, let desc):
                return errorMessage(code, desc)
        }
    }
}

public enum URLError: Error {
    case invalidURL
}

public enum DataError: Error {
    case unableToParse
    case dataNotFound
}
