//
// SearchResultRequestParams.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct SearchResultRequestParams: Codable {

    public var collectionName: String
    public var q: String
    public var perPage: Int

    public init(collectionName: String, q: String, perPage: Int) {
        self.collectionName = collectionName
        self.q = q
        self.perPage = perPage
    }

    public enum CodingKeys: String, CodingKey { 
        case collectionName = "collection_name"
        case q
        case perPage = "per_page"
    }

}
