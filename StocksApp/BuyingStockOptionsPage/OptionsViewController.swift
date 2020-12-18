//
//  OptionsViewController.swift
//  StocksApp
//
//  Created by Xing on 11/21/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import UIKit
import CoreData

class OptionsViewController: UITableViewController, UITextFieldDelegate, DatePricePickerTableViewControllerDelegate {
    
    /*
     * TAGS
     * 123 - Date Picker
     * 234 - Text Field
     * 777 - Last Modified Label
     * 999 - Selected Date
     * 1000 - Stock Name
     */
    
    //delegate stuff
    func callingViewController(_ controller: DatePricePickerTableViewController, didFinishEditing: Date) {
        DispatchQueue.main.async {
            self.selectedDate = didFinishEditing
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.selectedDateLabel?.text = formatter.string(from: self.selectedDate!)
            self.dateField?.date = didFinishEditing
            
            if self.textFieldLabel?.text != "" {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
            self.tableView.reloadData();
        }
        navigationController?.popViewController(animated:true)
    }
    
    var textFieldLabel: UITextField?
    var nameLabel: UILabel?
    var dateField: UIDatePicker?
    var symbolLabel: UILabel?
    var selectedDateLabel: UILabel?
    
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    var inputName: String?
    var inputSymbol: String?
    var selectedDate: Date?
    
    //urlsession & coredata variables
    var dataTask: URLSessionDataTask?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //computed variables
    var computedExchange: String?
    var computedSector: String?
    var computedIndustry: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        overviewSearch()
    }
    
    // MARK:- Table View Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if (indexPath.section == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "LeftRightItem", for: indexPath)
            
            let leftLabel = cell?.viewWithTag(10) as! UILabel
            let rightLabel = cell?.viewWithTag(20) as! UILabel
            
            switch indexPath.row {
            case 0:
                leftLabel.text = inputName
                rightLabel.text = inputSymbol
            case 1:
                leftLabel.text = "Exchange"
                rightLabel.text = computedExchange
            case 2:
                leftLabel.text = "Sector"
                rightLabel.text = computedSector
            case 3:
                leftLabel.text = "Industry"
                rightLabel.text = computedIndustry
            default:
                return UITableViewCell()
            }
        }
        if (indexPath.section == 1) {
            switch indexPath.row {
            case 0:
                let lastModifiedCell = tableView.dequeueReusableCell(withIdentifier: "LeftRightItem", for: indexPath)
                let leftLabel = lastModifiedCell.viewWithTag(10) as! UILabel
                let rightLabel = lastModifiedCell.viewWithTag(20) as! UILabel
                
                leftLabel.text = "Last Modified: "
                
                //checking if stock already exists
                //FROM: https://stackoverflow.com/questions/20794757/check-if-name-attribute-already-exists-in-coredata
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stock")
                let predicate = NSPredicate(format: "stockSymbol ==%@", inputSymbol!)
                request.predicate = predicate
                request.fetchLimit = 1
                
                do{
                    let tasks = try context.fetch(request)
                    if(tasks.count == 0){
                        rightLabel.text = "Not owned"
                    }
                    else {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        rightLabel.text = formatter.string(from: ((tasks[0]) as! Stock).lastTraded!)
                    }
                }
                catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
                
                cell = lastModifiedCell
            case 1:
                let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "datePickerItem", for: indexPath)
                dateField = datePickerCell.viewWithTag(199) as? UIDatePicker
                
                cell = datePickerCell
            case 2:
                let dateCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerItem", for: indexPath)
                selectedDateLabel = dateCell.viewWithTag(999) as? UILabel
                
                cell = dateCell
            case 3:
                let textCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldItem", for: indexPath)
                textFieldLabel = textCell.viewWithTag(234) as? UITextField
                textFieldLabel?.addTarget(self, action: #selector(OptionsViewController.textFieldDidChange(_:)), for: .editingChanged)
                
                cell = textCell
            default:
                cell = nil
            }
        }
        return cell ?? UITableViewCell()
    }
    
    // number of rows per section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 4
        }
        else if (section == 1) {
            return 4
        }
        else {
            return 0
        }
    }
    
    // number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // titles per section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return inputName
        }
        else if (section == 1) {
            return "Required Selections"
        }
        else {
            return "Error, this shouldn't be loaded"
        }
    }
    
    // system version is from stackOverflow
    // source: https://stackoverflow.com/questions/24503001/check-os-version-in-swift
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 && indexPath.section == 1 {
            let systemVersion = UIDevice.current.systemVersion
            if (systemVersion >= "14") {
                return UITableView.automaticDimension
            }
            else {
                return 216
            }
        }
        else {
            return UITableView.automaticDimension
        }
    }
    
    // MARK:- Table View Delegate
    // makes the textField show up immediately
    // idea of dispatching was from stackoverflow
    // source: https://stackoverflow.com/questions/25353687/swift-become-first-responder-on-uitextfield-not-working
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.textFieldLabel?.becomeFirstResponder()
        }
    }
    
    // when selecting outside, don't highlight
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath.row == 2 && indexPath.section == 1) {
            self.performSegue(withIdentifier: "datePricePickerSegue", sender: self)
            return indexPath
        }
        return nil
    }
    
    //date formatting was from a stack overflow post
    //source: https://stackoverflow.com/questions/42524651/convert-nsdate-to-string-in-ios-swift/42524767
    //there are other instances of this being used in my code but will only comment for this file
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toConfirmation" {
            let controller = segue.destination as! ConfirmationViewController
            controller.inputName = self.inputName
            controller.inputSymbol = self.inputSymbol
            controller.inputNumBought = Int((self.textFieldLabel?.text)!)
            controller.inputExchange = computedExchange
            controller.inputSector = computedSector
            controller.inputIndustry = computedIndustry
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            selectedDate = dateField?.date
            controller.inputDateDate = self.selectedDate
            controller.inputDateString = formatter.string(from: selectedDate!)
        }
        else if segue.identifier == "datePricePickerSegue" {
            let controller = segue.destination as! DatePricePickerTableViewController
            controller.delegate = self
            controller.inputSymbol = self.inputSymbol!
            
        }
    }
    
    // MARK:- Actions
    @IBAction func clickedConfirmButton(_ sender: Any) {
        let status: Int = dateField?.date.isValidDate(inputSymbol!, inputDate: dateField!.date) ?? -10
        if(status == 1) {
            performSegue(withIdentifier: "toConfirmation", sender: self)
        }
        else if(status == -1) {
            let alert = UIAlertController(title: "Please choose a day before today", message: "Stocks are not updated on the date of. Please choose an earlier day.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else if(status == -2) {
            let alert = UIAlertController(title: "Please choose a weekday", message: "Stocks are not updated on weekends so data is unavailable for this date", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else if(status == -3) {
            let alert = UIAlertController(title: "Please choose a day in the past", message: "Stocks are not updated on days in the future so data is unavailable for this date", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else if(status == -4) {
            let alert = UIAlertController(title: "Please choose an later date", message: "You chose a date more than 120 days ago. This is not allowed ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else if(status == -5) {
            let alert = UIAlertController(title: "Please choose an later date", message: "You chose a date before the last time you modified this stock. This is not allowed ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else if(status == -10) {
            //unsure what error happened
            let alert = UIAlertController(title: "Unsure what error occured", message: "Please report this error to the creator", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    // MARK:- Text Field Delegate
    // filters what comes into the textField
    // source: https://medium.com/mobile-app-development-publication/making-ios-uitextfield-accept-number-only-4e9f569ae0c6
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return (string.rangeOfCharacter(from: invalidCharacters) == nil)
    }
    
    
    // checks if the textField changes and if it is empty
    // source: https://stackoverflow.com/questions/28394933/how-do-i-check-when-a-uitextfield-changes
    @objc func textFieldDidChange(_ textField: UITextField) {
        if self.textFieldLabel?.text != "" {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    // MARK:- API
    func overviewStockAPI(searchText: String) -> URL {
        //let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(searchText)&apikey=RIS6IW1NU5CFX4VA"
        //let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(searchText)&apikey=LV9HE9JFT55SJZQO"
        let urlString = "https://www.alphavantage.co/query?function=OVERVIEW&symbol=\(searchText)&apikey=LV9HE9JFT55SJZQO"
        let url = URL(string: urlString)
        return url!
    }
    
    func overviewSearch() {
        dataTask?.cancel()
        let url = overviewStockAPI(searchText: inputSymbol!)
        let session = URLSession.shared
        dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error as NSError?, error.code == -999 {
                print("error")
                return
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                            self.computedExchange = (json["Exchange"])
                            self.computedSector = (json["Sector"])
                            self.computedIndustry = (json["Industry"])
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async {
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
