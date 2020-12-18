//
//  DatePricePickerTableViewController.swift
//  StocksApp
//
//  Created by Xing on 12/11/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import UIKit
import CoreData

protocol DatePricePickerTableViewControllerDelegate: class {
    func callingViewController(_ controller: DatePricePickerTableViewController, didFinishEditing: Date)
}

class DatePricePickerTableViewController: UITableViewController {
    
    var viableDates: [String: String] = [:]
    
    //input variables stuff that comes from its caller
    weak var delegate: DatePricePickerTableViewControllerDelegate?
    var inputSymbol: String?
    
    //API variables
    var dataTask: URLSessionDataTask?
    
    
    //coreData variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //computed variables
    var stockExists: Bool = false
    var foundStock: Stock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkStockExistance()
        performSearch()
    }
    
    // MARK:- Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viableDates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeftRightItem", for: indexPath)
        
        let leftLabel = cell.viewWithTag(10) as! UILabel
        let rightLabel = cell.viewWithTag(20) as! UILabel
        
        var keys = Array(viableDates.keys)
        
        if (stockExists) {
            keys = keys.sorted(by: <)
        }
        else { //stock doesnt exist
            keys = keys.sorted(by: >)
        }
        
        leftLabel.text = keys[indexPath.row] //setting the date
        rightLabel.text = viableDates[keys[indexPath.row]] //setting the price
        
        return cell
    }
    
    // MARK:- Helper Methods
    func trimDateList() {
        if (stockExists) {
            //we go through all the keys in dictionary, if they are not valid, get rid of them
            let keys = Array(viableDates.keys)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
            
            for key in keys {
                let date = dateFormatter.date(from: key)
                if (date?.isValidDate(self.inputSymbol!, inputDate: (foundStock?.lastTraded)!) != 1) { //is invalid date
                    viableDates.removeValue(forKey: key)
                }
            }
            
        }
    }
    
    func checkStockExistance() {
        //checking if stock already exists
        //FROM: https://stackoverflow.com/questions/20794757/check-if-name-attribute-already-exists-in-coredata
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stock")
        let predicate = NSPredicate(format: "stockSymbol == %@", inputSymbol!)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let tasks = try context.fetch(request)
            if(tasks.count == 0){ //doesn't exist
                stockExists = false
            }
            else {
                stockExists = true
                foundStock = tasks[0] as? Stock
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // MARK:- API Methods
    func stockAPI(searchText: String) -> URL {
        //let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(searchText)&apikey=RIS6IW1NU5CFX4VA"
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(searchText)&apikey=LV9HE9JFT55SJZQO"
        let url = URL(string: urlString)
        return url!
    }
    
    //jsonserialization was learned from external sources
    //source: https://www.hackingwithswift.com/example-code/system/how-to-parse-json-using-jsonserialization
    //also used in SellingConfrimationTableViewController
    func performSearch() {
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
                                let keys = Array(temp1!.keys).sorted(by: >)
                                
                                for key in keys { //key is a date
                                    let temp2 = (temp1?[key]) as? [String: Any]
                                    self.viableDates[key] = temp2?["1. open"] as? String
                                }
                            }
                        } catch let error as NSError {
                            print("Failed to load: \(error.localizedDescription)")
                        }
                        DispatchQueue.main.async {
                            self.trimDateList()
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
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var keys = Array(viableDates.keys)
        if (stockExists) {
            keys = keys.sorted(by: <)
        }
        else { //stock doesnt exist
            keys = keys.sorted(by: >)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        print("something should be happening")
        delegate?.callingViewController(self, didFinishEditing: dateFormatter.date(from: keys[indexPath.row])!)
        return indexPath
    }
}

// MARK:- Extending Date
extension Date{
    //checks if date is valid, returns different number based on error/success
    //extending came from external source
    //source: https://medium.com/infancyit/extend-those-native-classes-208bdf5b36f3
    func isValidDate(_ inputStockSymbol: String, inputDate: Date) -> Int {
        //have to check for multiple things
        //if date is before the lastModified date
        
        //used for checking the date
        let tempCalendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let currentDateTime = Date()
        
        //getting the stock if exists
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var stockDate: Date = Date()
        let tempDate = stockDate
        
        //checking if stock already exists
        //FROM: https://stackoverflow.com/questions/20794757/check-if-name-attribute-already-exists-in-coredata
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stock")
        let predicate = NSPredicate(format: "stockSymbol == %@", inputStockSymbol)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let tasks = try context.fetch(request)
            if(tasks.count == 0){
            }
            else {
                stockDate = ((tasks[0]) as! Stock).lastTraded!
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        //we should only compare the date components that matter
        let selfDay = tempCalendar.component(Calendar.Component.day, from: self)
        let selfMonth = tempCalendar.component(Calendar.Component.month, from: self)
        let selfYear = tempCalendar.component(Calendar.Component.year, from: self)
        
        let inputDay = tempCalendar.component(Calendar.Component.day, from: inputDate)
        let inputMonth = tempCalendar.component(Calendar.Component.month, from: inputDate)
        let inputYear = tempCalendar.component(Calendar.Component.year, from: inputDate)
        
        if (tempCalendar.isDateInToday(self)) {
            return -1
        }
        else if (tempCalendar.isDateInWeekend(self)) {
            return -2
        }
        else if (self > currentDateTime) { //is in the future
            return -3
        }
        else if (selfDay == inputDay && selfMonth == inputMonth && selfYear == inputYear) { //is of the same day, don't really care about time
            return 1
        }
        else if (tempCalendar.dateComponents([Calendar.Component.day], from: currentDateTime, to: inputDate).day! < -120)
        { //is more than 4 months ago
            return -4
        }
        else if (self < stockDate) { //is before lastUpdated
            if (tempDate == stockDate) { //don't own the stock yet
                return 1
            }
            // already own the stock
            return -5
        }
        
        //no errors occured, return success
        return 1
    }
    
}
