import Foundation

public struct Logger {
    var isDebug: Bool
    
    public init(debugMode: Bool = false) {
        isDebug = debugMode
    }
    
    func log(_ content: String) {
        if(isDebug) {
            print(content)
        }
    }
}
