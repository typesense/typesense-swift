//
//  Album.swift
//  AlbumSearchSwiftUI
//
//  Created by Sabesh Bharathi on 16/01/22.
//

import Foundation

public struct Album: Codable, Hashable {
    var name: String
    var artist: String
    var release_year: Int
    var genre: String
}
