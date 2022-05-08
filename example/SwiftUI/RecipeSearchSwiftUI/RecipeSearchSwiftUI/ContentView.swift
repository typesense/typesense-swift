//
//  ContentView.swift
//  RecipeSearchSwiftUI
//
//  Created by Sabesh Bharathi on 16/01/22.
//

import SwiftUI
import Typesense

struct ContentView: View {
    @State private var queryString = ""
    @State private var hits: [SearchResultHit<Recipe>] = []
    @State private var showingSheet = false
    @State private var selectedRecipe: Recipe? = nil
    
    let client: Client
    
    init() {
        let config = Configuration(nodes: [Node(host: "qtg5aekc2iosjh93p.a1.typesense.net", port: "443", nodeProtocol: "https")], apiKey: "8hLCPSQTYcBuK29zY5q6Xhin7ONxHy99")
        client = Client(config: config)
    }
    
    var body: some View {
        NavigationView {
        
            List(hits, id: \.document){ hit in
              Button {
                selectedRecipe = hit.document
              } label: {
                VStack(alignment: .leading) {
                  Text(hit.document!.title)
                        .font(.headline)
                    HStack{
                      Text("From " + getFoodProvider(link: hit.document?.link ?? "N/A"))
                    }
                    .font(.caption)
                  
                  
                  Text(attachIngredients(recipe: hit.document))
                    .padding(.top, 5)
                }
                .padding(.vertical, 2)
              }.buttonStyle(.plain)

               
            }
            .navigationTitle("Search Recipes 🥘")
        }
        .sheet(item: $selectedRecipe) { chosenItem in
          RecipeDetailView(recipe: chosenItem)
        }
        .searchable(text: $queryString)
        .onChange(of: queryString) { quer in
          fetchRecipes(searchQuery: quer, quer == "" ? true : false)
        }
        .onAppear {
          fetchRecipes(searchQuery: "", true)
        }
    }
  
  private func fetchRecipes(searchQuery: String, _ initialRecipes: Bool = false) {
      let collectionParams = MultiSearchCollectionParameters(q: searchQuery, collection: "r")
      let searchParams = MultiSearchParameters(queryBy: "title", perPage: initialRecipes ? 8 : 25)
        Task {
            do {
              print("here")
              let (data, _) = try await client.multiSearch().perform(searchRequests: [collectionParams], commonParameters: searchParams, for: Recipe.self)
              hits = (data?.results[0].hits) ?? []
            } catch (let error) {
                print(error.localizedDescription)
            }
        }
    }
  
  private func getFoodProvider(link: String) -> String {
    let first = link.split(separator: ".")[0]
    if first.contains("www") {
      let second = link.split(separator: ".")[1]
      return String(second + ".com")
    }
    return String(first + ".com")
  }
  
  private func attachIngredients(recipe: Recipe?) -> String {
    
    guard let recipe = recipe else {
      return ""
    }

    var displayString = ""
    let list = recipe.ingredient_names
    for index in 0..<list.count {
      if index < 5 {
        displayString.append(contentsOf: list[index].capitalized)
        if index != 4 {
          displayString.append(contentsOf: ", ")
        }
      }
    }
    if list.count > 5 {
      displayString.append(contentsOf: " and more!")
    }
    
    return displayString
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 13 Pro")
    }
}
