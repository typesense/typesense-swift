//
//  RecipeDetailView.swift
//  RecipeSearchSwiftUI
//
//  Created by Sabesh Bharathi on 08/05/22.
//

import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.dismiss) var dismiss
  
    var recipe: Recipe?
    var body: some View {
      if let recipe = recipe {
        List {
          
          HStack {
            Text(recipe.title)
              .font(.title)
              .bold()
            Spacer()
            Text("🍴")
              .font(.system(size: 60))
          }
            
            .padding(10)
          
          Section(header: Text("Ingredients")) {
            ForEach(recipe.ingredients_with_measurements, id: \.self) { ingredient in
              Text(ingredient)
            }
          }
          
          Section(header: Text("Cooking Directions")) {
            ForEach(recipe.directions, id: \.self) { direction in
                Text("\(recipe.directions.firstIndex(of: direction)! + 1). " + direction)
            }
          }
          
          HStack {
            Spacer()
            Button {
              if let url = URL(string: recipe.link) {
                  if UIApplication.shared.canOpenURL(url) {
                      UIApplication.shared.open(url, options: [:])
                  }
              }
            } label: {
              Text("Explore")
            }
            Spacer()
          }
          
        }
      }
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailView()
    }
}
