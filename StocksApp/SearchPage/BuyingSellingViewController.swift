//
//  BuyingSellingViewController.swift
//  StocksApp
//
//  Created by Xing on 11/11/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    
    // will pull items using API later, atm using temp values
    // https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=APPL&apikey=RIS6IW1NU5CFX4VA
    /*
    var items = [StockItem]()
    
    var passedName: String?
    var passedPrice: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item1 = StockItem()
        item1.name = "APPL"
        item1.price = 50000
        items.append(item1)
        
        let item2 = StockItem()
        item2.name = "MSFT"
        item2.price = 12345
        items.append(item2)
        
        let item3 = StockItem()
        item3.name = "RIOT"
        item3.price = 23412
        items.append(item3)
        
        // need to make a new object to hold json results?
        /*
         let url = URL(string: "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=APPL&apikey=RIS6IW1NU5CFX4VA")!
         let session = URLSession.shared
         let dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
         print(response!)
         })
         dataTask.resume()
         */
        
    }
    
    // MARK:- Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockItem", for: indexPath)
        
        let item = items[indexPath.row]
        
        let nameLabel = cell.viewWithTag(1000) as! UILabel
        let priceLabel = cell.viewWithTag(2000) as! UILabel
        
        nameLabel.text = item.name
        priceLabel.text = String(item.price)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChoosenStockSegue" {
            let controller = segue.destination as! OptionsViewController
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.inputName = items[indexPath.row].name
                controller.inputPrice = String(items[indexPath.row].price)
            }
        }
    }
    */
    
//    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var tableView: UITableView!
    
}
