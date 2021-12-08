//
// MultiSearchResponse.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct MultiSearchResponse<T: Codable>: Codable {

    public var results: [SearchResult<T>]?

    public init(results: [SearchResult<T>]? = nil) {
        self.results = results
    }


}