//
//  ViewController.swift
//  AlbumSearchUIKit
//
//  Created by Sabesh Bharathi on 04/01/22.
//

import UIKit
import Typesense

class ViewController: UIViewController, UISearchResultsUpdating {

    @IBOutlet weak var hitsTableView: UITableView!
    
    var hits:[SearchResultHit<Album>]
    
    class HitsViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
        }
    }
    
    let searchController = UISearchController(searchResultsController: HitsViewController())
    let client: Client
    
    required init?(coder aDecoder: NSCoder) {
        let config = Configuration(nodes: [Node(host: "wtvd81hcmy72zk93p-1.a1.typesense.net", port: "443", nodeProtocol: "https")], apiKey: "UWw2DFoNUNWDDEWZr0gixdSLZU5SGKIs", logger: Logger(debugMode: true))
        self.client = Client(config: config)
        self.hits = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        hitsTableView.delegate = self
        hitsTableView.dataSource = self
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        
        let searchParams = SearchParameters(q: text, queryBy: "name")
        
        Task {
            do {
                let (data, _) = try await client.collection(name: "albums").documents().search(searchParams, for: Album.self)
                self.hits = (data?.hits) ?? []
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
        let album = hits[indexPath.row].document
        var cell = hitsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let artist = album?.artist
        let genre = album?.genre
        let releaseYear = album?.release_year
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = album?.name
            content.secondaryText = "\(artist!) - \(genre!) - \(releaseYear!)"
            cell.contentConfiguration = content
        } else {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                            reuseIdentifier: "cell")
            cell.textLabel?.text = album?.name
            cell.detailTextLabel?.text = "\(artist!) - \(genre!) - \(releaseYear!)"
        }
        
        return cell
    }
}


