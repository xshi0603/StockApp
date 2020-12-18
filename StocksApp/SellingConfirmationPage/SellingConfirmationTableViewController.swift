//
//  SellingConfirmationTableViewController.swift
//  StocksApp
//
//  Created by Xing on 12/5/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox

class SellingConfirmationTableViewController: UITableViewController {
    
    /*
     * TAGS
     * 1000 - Stock Name
     * 2000 - Stock Symbol
     * 3000 - currPrice
     * 4000 - numSold
     * 5000 - totalPrice
     */
    
    //labels
    var nameLabel: UILabel?
    var symbolLabel: UILabel?
    var currPriceLabel: UILabel?
    var numSoldLabel: UILabel?
    var totalPriceLabel: UILabel?
    var netDifferenceLabel: UILabel?
    
    //input variables
    var inputDate: Date?
    var inputNumSold: String?
    var inputStock: Stock?
    
    //computed variables
    var oldValue: Float?
    var diffValue: Float?
    var pricePer: String?
    var totalPrice: Float?
    
    //coreData variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //API variables
    var dataTask: URLSessionDataTask?
    
    //variable for sounds
    var soundID: SystemSoundID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSoundEffect("Sound.caf")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateAsString = formatter.string(from: inputDate!)
        
        oldValue = inputStock?.totalValue
        performSearch(searchDate: dateAsString)
    }
    
    // MARK:- Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        switch indexPath.row {
        case 0:
            let currViewCell = tableView.dequeueReusableCell(withIdentifier: "CurrViewItem", for: indexPath)
            nameLabel = currViewCell.viewWithTag(1000) as? UILabel
            symbolLabel = currViewCell.viewWithTag(2000) as? UILabel
            
            nameLabel?.text = inputStock?.stockName
            symbolLabel?.text = inputStock?.stockSymbol
            
            cell = currViewCell
        case 1:
            let priceCell = tableView.dequeueReusableCell(withIdentifier: "CurrPriceItem", for: indexPath)
            currPriceLabel = priceCell.viewWithTag(3000) as? UILabel
            
            if let floatValue = Float(self.pricePer ?? "0") {
                //currPriceLabel?.text = String(format: "%.2f", floatValue)
                currPriceLabel?.text = floatToCurrency(floatValue)
            } else {
                currPriceLabel?.text = "Float error"
            }
            
            cell = priceCell
        case 2:
            let numSoldCell = tableView.dequeueReusableCell(withIdentifier: "NumSoldItem", for: indexPath)
            numSoldLabel = numSoldCell.viewWithTag(4000) as? UILabel
            
            numSoldLabel?.text = inputNumSold?.description
            
            cell = numSoldCell
        case 3:
            let totalPriceCell = tableView.dequeueReusableCell(withIdentifier: "TotalPriceItem", for: indexPath)
            totalPriceLabel = totalPriceCell.viewWithTag(5000) as? UILabel
            
            //totalPriceLabel?.text = String(format: "%.2f", totalPrice ?? 0.0)
            totalPriceLabel?.text = floatToCurrency(totalPrice ?? 0.0)
            
            cell = totalPriceCell
        case 4:
            let netDifferenceCell = tableView.dequeueReusableCell(withIdentifier: "NetDifferenceItem", for: indexPath)
            netDifferenceLabel = netDifferenceCell.viewWithTag(12345) as? UILabel
            
            //totalPriceLabel?.text = String(format: "%.2f", totalPrice ?? 0.0)
            /*
            if let floatValue = Float(self.pricePer ?? "0") {
                let numSold:Int64 = Int64((self.inputNumSold)!)!
                let newAmountOwned = inputStock!.amountOwned - numSold
                let newValue = floatValue * Float(newAmountOwned)
                netDifferenceLabel?.text = newValue.description
            } else {
                netDifferenceLabel?.text = "Float error"
            }
            */
            cell = netDifferenceCell
        default:
            cell = nil
        }
        return cell ?? UITableViewCell()
    }
    
    // when selecting outside, don't highlight
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    // MARK: - API Functions
    func stockAPI(searchText: String) -> URL {
        //let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(searchText)&apikey=RIS6IW1NU5CFX4VA"
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(searchText)&apikey=LV9HE9JFT55SJZQO"
        let url = URL(string: urlString)
        return url!
    }
    
    func performSearch(searchDate: String) {
        dataTask?.cancel()
        //isLoading = true //maybe implement later
        
        let url = stockAPI(searchText: (inputStock?.stockSymbol)!)
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
                            }
                        } catch let error as NSError {
                            print("Failed to load: \(error.localizedDescription)")
                        }
                        DispatchQueue.main.async {
                            if let floatValue = Float(self.pricePer ?? "0") {
                                if (floatValue == 0) {
                                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                                    let alert = UIAlertController(title: "Please try again later", message: "Unfortunately our API can only handle so many requests. Please try again in about a minute.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(alert, animated: true)
                                }
                                self.totalPrice = floatValue * Float(self.inputNumSold!)!
                                
                                //calculating difference
                                let numSold:Int64 = Int64((self.inputNumSold)!)!
                                let newAmountOwned = self.inputStock!.amountOwned - numSold
                                let newValue = floatValue * Float(newAmountOwned)
                                let newSpent = self.inputStock!.totalSpent - floatValue * Float(numSold)
                                
                                let stockValue: Float = self.inputStock?.totalValue ?? 10.0
                                let stockSpent: Float = self.inputStock?.totalSpent ?? 0.0
                                let stockDifference: Float = stockValue - stockSpent
                                
                                let newDiff = (newValue - newSpent) - stockDifference

                                self.netDifferenceLabel?.text = floatToCurrency(newDiff)
                                if (newDiff >= 0) { //positive
                                    self.netDifferenceLabel?.textColor = UIColor(red: 0.01, green: 0.5, blue: 0.2, alpha: 1)
                                }
                                else {
                                    self.netDifferenceLabel?.textColor = UIColor.red
                                }
                            } else {
                                print("Float error")
                            }
                            self.tableView.reloadData();
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
    
    //updates the coreData w/ the info from performSearch()
    func updateCoreData() {
        let numSold:Int64 = Int64((self.inputNumSold)!)!
        inputStock?.amountOwned -= numSold
        inputStock?.lastTraded = inputDate
        
        //recalculate totalValue & totalSpent
        if let floatValue = Float(self.pricePer!) {
            let totalNumBought = inputStock?.amountOwned
            inputStock?.totalValue = floatValue * Float(totalNumBought!)
            inputStock?.totalSpent -= floatValue * Float(numSold)
        } else {
            print("Float error")
        }
        
        do {
            try self.context.save()
        }
        catch {
            print("Some error happened when trying to update the core data")
        }
    }
    
    // MARK: - Actions
    @IBAction func pressedConfirmButton(_ sender: Any) {
        updateCoreData()
        self.playSoundEffect()
        
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        hudView.text = "Sold"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            hudView.hide()
            self.navigationController?.popToRootViewController(animated: true)
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
