//
//  Recipe.swift
//  RecipeSearchUIKit
//
//  Created by Sabesh Bharathi on 04/01/22.
//

import Foundation

public struct Recipe: Codable, Hashable, Identifiable {
  var directions: [String]
  public var id: String
  var ingredient_names: [String]
  var ingredients_with_measurements: [String]
  var link: String
  var recipe_id: Int
  var title: String
}

