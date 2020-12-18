//
//  ConfirmationViewController.swift
//  StocksApp
//
//  Created by Xing on 11/25/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox

class ConfirmationViewController: UITableViewController {
    
    /*
     * TAGS
     * 1000 - Stock Name
     * 2000 - Stock Symbol
     * 3000 - currPrice
     * 4000 - numBought
     * 5000 - totalPrice
     */
    
    //labels & fields
    var nameLabel: UILabel?
    var symbolLabel: UILabel?
    var priceField: UILabel?
    var numBoughtField: UILabel?
    var totalPriceField: UILabel?
    
    //input variables
    var inputName: String?
    var inputSymbol: String?
    var pricePer: String?
    var inputNumBought: Int?
    var inputDateString: String?
    var inputDateDate: Date?
    var inputExchange: String?
    var inputSector: String?
    var inputIndustry: String?
    
    //computed variables
    var computedTotalPrice: Float?
    var computedExchange: String?
    var computedSector: String?
    var computedIndustry: String?
    
    //urlsession & coredata variables
    var dataTask: URLSessionDataTask?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //variable for sounds
    var soundID: SystemSoundID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSoundEffect("Sound.caf")
        performSearch(searchDate: self.inputDateString!)
    }
    
    // MARK:- API Functions
    func stockAPI(searchText: String) -> URL {
        //let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(searchText)&apikey=RIS6IW1NU5CFX4VA"
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(searchText)&apikey=LV9HE9JFT55SJZQO"
        let url = URL(string: urlString)
        return url!
    }
    
    //jsonserialization was learned from external sources
    //source: https://www.hackingwithswift.com/example-code/system/how-to-parse-json-using-jsonserialization
    //also used in SellingConfrimationTableViewController
    func performSearch(searchDate: String) {
        dataTask?.cancel()
        
        let url = stockAPI(searchText: inputSymbol!)
        let session = URLSession.shared
        dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error as NSError?, error.code == -999 {
                return
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data {
                    let status = errorParse(data: data)
                    if (status == "Thank you for using Alpha Vantage! Our standard API call frequency is 5 calls per minute and 500 calls per day. Please visit https://www.alphavantage.co/premium/ if you would like to target a higher API call frequency.") {
                        DispatchQueue.main.async {
                            self.navigationItem.rightBarButtonItem?.isEnabled = false
                            let alert = UIAlertController(title: "Please try again later", message: "Unfortunately our API can only handle so many requests. Please try again in about a minute.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                        return
                    }
                    else {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                let temp1 = (json["Time Series (Daily)"]) as? [String: Any]
                                let temp2 = (temp1?[searchDate]) as? [String: String]
                                self.pricePer = temp2?["1. open"]!
                                if let floatValue = Float(self.pricePer ?? "0.0") {
                                    if (floatValue == 0) {
                                        DispatchQueue.main.async {
                                            self.navigationItem.rightBarButtonItem?.isEnabled = false
                                        }
                                        let alert = UIAlertController(title: "Stock error", message: "You are likely trying to find information about a stock when the stock markets were closed. Please choose another date.", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        self.present(alert, animated: true)
                                    }
                                }
                            }
                        } catch let error as NSError {
                            print("Failed to load: \(error.localizedDescription)")
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData();
                            if let floatValue = Float(self.pricePer ?? "0.0") {
                                self.priceField?.text = floatToCurrency(floatValue)
                                self.computedTotalPrice = floatValue * Float(self.inputNumBought!)
                                self.totalPriceField?.text = floatToCurrency(self.computedTotalPrice!)
                            } else {
                                print("Float error")
                            }
                        }
                        return
                    }
                }
            } else {
                print("Failure! \(response!)")
            }
        })
        dataTask?.resume()
    }
    
    
    // MARK:- Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        
        switch indexPath.row {
        case 0:
            let currViewCell = tableView.dequeueReusableCell(withIdentifier: "CurrViewItem", for: indexPath)
            nameLabel = currViewCell.viewWithTag(1000) as? UILabel
            symbolLabel = currViewCell.viewWithTag(2000) as? UILabel
            
            nameLabel?.text = inputName
            symbolLabel?.text = inputSymbol
            
            cell = currViewCell
        case 1:
            let priceCell = tableView.dequeueReusableCell(withIdentifier: "CurrPriceItem", for: indexPath)
            priceField = priceCell.viewWithTag(3000) as? UILabel
            
            cell = priceCell
        case 2:
            let numBoughtCell = tableView.dequeueReusableCell(withIdentifier: "NumBoughtItem", for: indexPath)
            numBoughtField = numBoughtCell.viewWithTag(4000) as? UILabel
            numBoughtField?.text = String(inputNumBought!)
            
            cell = numBoughtCell
        case 3:
            let totalPriceCell = tableView.dequeueReusableCell(withIdentifier: "TotalPriceItem", for: indexPath)
            totalPriceField = totalPriceCell.viewWithTag(5000) as? UILabel
            
            cell = totalPriceCell
            
        default:
            cell = nil
        }
        return cell ?? UITableViewCell()
    }
    
    // when selecting outside, don't highlight
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    // MARK:- Actions
    @IBAction func confirm(_ sender: Any) {
        //checking if stock already exists
        //FROM: https://stackoverflow.com/questions/20794757/check-if-name-attribute-already-exists-in-coredata
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stock")
        let predicate = NSPredicate(format: "stockSymbol == %@", inputSymbol!)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let tasks = try context.fetch(request)
            if(tasks.count == 0){
                // no existing element, make stock object
                let stock = Stock(context: context)
                stock.stockName = inputName
                stock.stockSymbol = inputSymbol
                stock.amountOwned = Int64(inputNumBought!)
                stock.totalValue = computedTotalPrice!
                stock.totalSpent = computedTotalPrice!
                stock.lastTraded = inputDateDate
                stock.exchange = inputExchange
                stock.sector = inputSector
                stock.industry = inputIndustry
                // save stock object into context
                try! context.save()
            }
            else{
                // at least one matching object exists, modify the object
                ((tasks[0]) as! Stock).amountOwned += Int64(inputNumBought!)
                ((tasks[0]) as! Stock).totalSpent += computedTotalPrice!
                ((tasks[0]) as! Stock).lastTraded = inputDateDate
                // need to recompute totalValue
                if let floatValue = Float(self.pricePer!) {
                    let totalNumBought = ((tasks[0]) as! Stock).amountOwned
                    ((tasks[0]) as! Stock).totalValue = floatValue * Float(totalNumBought)
                } else {
                    print("Float error")
                }
            }
            self.playSoundEffect()
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        hudView.text = "Bought"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            hudView.hide()
            let tempSearchController = self.navigationController?.viewControllers[1];
            self.navigationController?.popToViewController(tempSearchController!, animated: true)
        })
        
    }
    
    // MARK:- Sound effects
    func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound: \(path)")
            }
        }
    }
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }
}
