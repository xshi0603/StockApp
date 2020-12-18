//
//  BuyingSellingViewController.swift
//  StocksApp
//
//  Created by Xing on 11/11/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var hasSearched = false
    var searchResults = [SearchResult]()
    var dataTask: URLSessionDataTask?
    
    //loading nib stuff
    static let loadingCell = "LoadingCell"
    var isLoading = false
    
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from:data)
            return result.bestMatches
        } catch {
            print("JSON Error+: \(error)")
            return []
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        let cellNib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "LoadingCell")
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchAPI(searchText: String) -> URL {
        //let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(searchText)&apikey=RIS6IW1NU5CFX4VA"
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(encodedText)&apikey=LV9HE9JFT55SJZQO"
        let url = URL(string: urlString)
        return url!
    }
    
    func performSearch() {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            dataTask?.cancel()
            tableView.reloadData()
            hasSearched = true
            searchResults = []
            DispatchQueue.main.async {
                self.isLoading = true
                self.tableView.reloadData();
            }
            let url = searchAPI(searchText: searchBar.text!)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
                if let error = error as NSError?, error.code == -999 {
                    return
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data {
                        let status = errorParse(data: data)
                        if (status == "Thank you for using Alpha Vantage! Our standard API call frequency is 5 calls per minute and 500 calls per day. Please visit https://www.alphavantage.co/premium/ if you would like to target a higher API call frequency. Thank you!") {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Please try again later", message: "Unfortunately our API can only handle so many requests. Please try again in about a minute.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true)
                            }
                            return
                        }
                        self.searchResults = self.parse(data: data)
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData();
                        }
                        return
                    }
                } else {
                    print("Failure! \(response!)")
                }
            })
            dataTask?.resume()
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultCell"
        
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier:"LoadingCell", for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        if searchResults.count == 0 {
            cell.textLabel!.text = "Nothing found"
            cell.detailTextLabel!.text = ""
        } else {
            let searchResult = searchResults[indexPath.row]
            cell.textLabel!.text = searchResult.name
            cell.detailTextLabel!.text = searchResult.symbol
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "OptionsViewController") as! OptionsViewController
        
        controller.inputName = searchResults[indexPath.row].name
        controller.inputSymbol = searchResults[indexPath.row].symbol
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (searchResults.count == 0 || isLoading) {
            return nil
        } else {
            return indexPath
        }
    }
    
    // makes the textField show up immediately
    // idea of dispatching was from stackoverflow
    // source: https://stackoverflow.com/questions/25353687/swift-become-first-responder-on-uitextfield-not-working
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.text = ""
        searchResults = []
        DispatchQueue.main.async {
            self.hasSearched = false
            self.searchBar?.becomeFirstResponder()
            self.tableView.reloadData()
        }
    }
}
