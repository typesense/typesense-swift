//
//  Recipe.swift
//  RecipeSearchSwiftUI
//
//  Created by Sabesh Bharathi on 16/01/22.
//

import Foundation

public struct Recipe: Codable, Hashable {  
  var directions: [String]
  var id: String
  var ingredient_names: [String]
  var ingredients_with_measurements: [String]
  var link: String
  var recipe_id: Int
  var title: String
}
