//
//  ViewController.swift
//  RecipeSearchUIKit
//
//  Created by Sabesh Bharathi on 04/01/22.
//

import UIKit
import Typesense

class ViewController: UIViewController, UISearchResultsUpdating {

    @IBOutlet weak var hitsTableView: UITableView!
    
    var hits:[SearchResultHit<Recipe>]
    
    class HitsViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
        }
    }
    
    let searchController = UISearchController(searchResultsController: HitsViewController())
    let client: Client
    
    required init?(coder aDecoder: NSCoder) {
        let config = Configuration(nodes: [Node(host: "qtg5aekc2iosjh93p.a1.typesense.net", port: "443", nodeProtocol: "https")], apiKey: "8hLCPSQTYcBuK29zY5q6Xhin7ONxHy99")
        self.client = Client(config: config)
        self.hits = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search Recipes 🥘"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        hitsTableView.delegate = self
        hitsTableView.dataSource = self
        updateSearchResults(for: UISearchController())
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        
        let collectionParams = MultiSearchCollectionParameters(q: text, collection: "r")
        let searchParams = MultiSearchParameters(queryBy: "title", perPage: 25)
        
        Task {
            do {
                let (data, _) = try await client.multiSearch().perform(searchRequests: [collectionParams], commonParameters: searchParams, for: Recipe.self)
                self.hits = (data?.results[0].hits) ?? []
                self.hitsTableView.reloadData()
            } catch (let error) {
                print(error.localizedDescription)
            }
        }
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipe = hits[indexPath.row].document
        var cell = hitsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = recipe?.title
            cell.contentConfiguration = content
        } else {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                            reuseIdentifier: "cell")
            cell.textLabel?.text = recipe?.title
        }
        
        return cell
    }
}


