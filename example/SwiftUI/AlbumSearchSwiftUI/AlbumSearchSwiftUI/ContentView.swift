//
//  ContentView.swift
//  AlbumSearchSwiftUI
//
//  Created by Sabesh Bharathi on 16/01/22.
//

import SwiftUI
import Typesense

struct ContentView: View {
    @State private var queryString = ""
    @State private var hits: [SearchResultHit<Album>] = []
    
    let client: Client
    
    init() {
        let config = Configuration(nodes: [Node(host: "wtvd81hcmy72zk93p-1.a1.typesense.net", port: "443", nodeProtocol: "https")], apiKey: "UWw2DFoNUNWDDEWZr0gixdSLZU5SGKIs")
        client = Client(config: config)
    }
    
    var body: some View {
        NavigationView {
        
            List(hits, id: \.document){ hit in
                VStack(alignment: .leading) {
                    Text(hit.document!.name)
                        .font(.headline)
                    HStack{
                        Text(hit.document!.artist + " -")
                        Text(hit.document!.genre + " -")
                        Text(String(hit.document!.release_year))
                    }
                    .font(.caption)
                }
                .padding(.vertical, 2)
            }
            .navigationTitle("Search")
        }
        .searchable(text: $queryString)
        .onChange(of: queryString) { quer in
            let searchParams = SearchParameters(q: quer, queryBy: "name")
            Task {
                do {
                    let (data, _) = try await client.collection(name: "albums").documents().search(searchParams, for: Album.self)
                    hits = (data?.hits) ?? []
                } catch (let error) {
                    print(error.localizedDescription)
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 13 Pro")
    }
}
