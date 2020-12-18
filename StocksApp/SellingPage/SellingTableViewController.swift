//
//  SellingTableViewController.swift
//  StocksApp
//
//  Created by Xing on 12/3/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import UIKit

class SellingTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items:[Stock]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCoreData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items?.count == 0 {
            return 1
        } else {
            return items?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultCell"
        
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        if items!.count == 0 {
            cell.textLabel!.text = "No stocks owned"
            cell.detailTextLabel!.text = ""
        } else {
            let stock = items?[indexPath.row]
            cell.textLabel!.text = stock?.stockName
            cell.detailTextLabel!.text = stock?.stockSymbol
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (items?.count != 0) {
            let controller = storyboard!.instantiateViewController(withIdentifier: "SellingOptionsTableViewController") as! SellingOptionsTableViewController
            controller.inputStock = items?[indexPath.row]
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    // when selecting outside, don't highlight
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (items?.count == 0) {
            return nil
        }
        else {
            return indexPath
        }
    }
    
    // MARK: - Helper Methods
    func fetchCoreData() {
        do {
            self.items = try context.fetch(Stock.fetchRequest())
        }
        catch {
            print("Ran into an error when fetching coredata, please try again")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData();
        }
    }
    
}
