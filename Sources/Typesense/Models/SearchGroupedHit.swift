//
// SearchGroupedHit.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct SearchGroupedHit<T: Codable>: Codable {

    public var found: Int?
    public var groupKey: [Any]
    /** The documents that matched the search query */
    public var hits: [SearchResultHit<T>]

    public init(found: Int? = nil, groupKey: [Any], hits: [SearchResultHit<T>]) {
        self.found = found
        self.groupKey = groupKey
        self.hits = hits
    }

    public enum CodingKeys: String, CodingKey { 
        case found
        case groupKey = "group_key"
        case hits
    }

}
