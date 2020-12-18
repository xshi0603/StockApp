//
//  HomePageViewController.swift
//  StocksApp
//
//  Created by Xing on 11/21/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import UIKit
import CoreData
import StoreKit

class HomePageViewController: UITableViewController {
    
    //need to calculate these values by looping through all stocks
    var currSpent: Float = 0
    var currValue: Float = 0
    var currDifference: Float = 0
    
    //coreData variables
    let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
    var stocks:[Stock]?
    
    //userDefaults variables
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        reset()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    // adding a segue to an alert button was from external source
    // source: https://stackoverflow.com/questions/28591514/uialertcontroller-segue-to-different-page-swift
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
        if (defaults.integer(forKey: "TimesOpened") == 0) {
            //first time opening app
            defaults.set(1, forKey: "TimesOpened")
            let alert = UIAlertController(title: "Welcome to StockApp!", message: "Since this is your first time visiting, please visit our help page for a guide on using this app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Take me there!", style: .default, handler: {
                action in self.performSegue(withIdentifier: "segueToHelp", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "I'd rather explore myself", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        else {
            //if times visited homescreen is 10, ask user to review app
            if (defaults.integer(forKey: "TimesOpened") == 10) {
                AppStoreReviewManager.requestReviewIfAppropriate()
            }
            //increment amount of times visited home by one
            defaults.set(defaults.integer(forKey: "TimesOpened") + 1, forKey: "TimesOpened")
        }
        fetchCoreData()
    }
    
    // MARK:- Table View Data Source
    //floating point formatting was from stackOverflow
    //source:https://www.hackingwithswift.com/example-code/strings/how-to-specify-floating-point-precision-in-a-string
    //also seen in other views which display dollars
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomePageItem", for: indexPath)
        
        let leftLabel = cell.viewWithTag(10) as! UILabel
        let rightLabel = cell.viewWithTag(20) as! UILabel
        
        if (indexPath.section == 0) {
            if indexPath.row == 0 {
                leftLabel.text = "Currently Spent:"
                //rightLabel.text = String(format: "%.2f", currSpent)
                rightLabel.text = floatToCurrency(currSpent)
            } else if indexPath.row == 1 {
                leftLabel.text = "Current Value:"
                //rightLabel.text = String(format: "%.2f", currValue)
                rightLabel.text = floatToCurrency(currValue)
            } else if indexPath.row == 2 {
                leftLabel.text = "Current Difference:"
                //rightLabel.text = String(format: "%.2f", currDifference)
                rightLabel.text = floatToCurrency(currDifference)
                if (currDifference >= 0) { //positive
                    rightLabel.textColor = UIColor(red: 0.01, green: 0.5, blue: 0.2, alpha: 1)
                }
                else {
                    rightLabel.textColor = UIColor.red
                }
            }
        }
        else {
            let stock = stocks?[indexPath.row]
            leftLabel.text = stock?.stockName
            let stockValue: Float = stock?.totalValue ?? 10.0
            let stockSpent: Float = stock?.totalSpent ?? 0.0
            let stockDifference: Float = stockValue - stockSpent
            rightLabel.text = floatToCurrency(stockDifference)
            if (stockDifference >= 0) { //positive
                rightLabel.textColor = UIColor(red: 0.01, green: 0.5, blue: 0.2, alpha: 1)
            }
            else {
                rightLabel.textColor = UIColor.red
            }
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK:- Table Group Methods
    // number of rows per section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 3
        }
        else if (section == 1) {
            return stocks?.count ?? 0
        }
        else {
            return 0
        }
    }
    
    // number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (stocks?.count == 0) {
            return 1
        }
        else {
            return 2
        }
    }
    
    // titles per section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Stock Infomation"
        }
        else if (section == 1) {
            return "Owned Stocks"
        }
        else {
            return "Error, this shouldn't be loaded"
        }
    }
    
    // MARK:- Helper Methods
    func reset() {
        DispatchQueue.main.async {
            self.currSpent = 0
            self.currValue = 0
            self.currDifference = 0
            self.resetCoreData()
            self.resetUserDefaults()
            self.fetchCoreData()
            self.tableView.reloadData()
        }
    }
    
    // this reset fnc is taken off stackoverflow, only used for testing purposes
    // source: https://stackoverflow.com/questions/1383598/core-data-quickest-way-to-delete-all-instances-of-an-entity
    func resetCoreData() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Stock")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    
    func resetUserDefaults() {
        defaults.set(0, forKey: "TimesOpened")
    }
    
    func fetchCoreData() {
        do {
            self.stocks = try context.fetch(Stock.fetchRequest())
        }
        catch {
            print("Ran into an error when fetching coredata, please try again")
        }
        
        DispatchQueue.main.async {
            self.currSpent = 0
            self.currValue = 0
            for stock in self.stocks! {
                self.currSpent += stock.totalSpent
                self.currValue += stock.totalValue
            }
            self.currDifference = self.currValue - self.currSpent
            self.tableView.reloadData();
        }
    }
    
    @IBAction func resetButton(_ sender: Any) {
        let alert = UIAlertController(title: "Warning!", message: "This will erased ALL of your owned stocks. However, this will also reset your stock dates allowing you to trade from previously unaccessable dates.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reset, wipe my stocks", style: .destructive, handler: {
            action in self.reset()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
