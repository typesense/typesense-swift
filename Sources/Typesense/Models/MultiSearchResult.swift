//
// MultiSearchResult.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct MultiSearchResult<T: Codable>: Codable {

    public var results: [SearchResult<T>]

    public init(results: [SearchResult<T>]) {
        self.results = results
    }


}
