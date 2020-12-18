//
//  SellingConfirmationTableViewController.swift
//  StocksApp
//
//  Created by Xing on 12/3/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import UIKit


class SellingOptionsTableViewController: UITableViewController, UITextFieldDelegate, DatePricePickerTableViewControllerDelegate {
    
    /*
     * TAGS
     * 1000 - Stock Name
     * 2000 - Stock Symbol
     * 3001 - currOwned
     * 4001 - totalValue
     * 5001 - totalSpent
     * 123 - Date Picker
     * 234 - Text Field
     */
    
    //delegate stuff
    var selectedDate: Date?
    
    func callingViewController(_ controller: DatePricePickerTableViewController, didFinishEditing: Date) {
        DispatchQueue.main.async {
            self.selectedDate = didFinishEditing
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.selectedDateLabel?.text = formatter.string(from: self.selectedDate!)
            self.dateField?.date = didFinishEditing
            
            if self.textField?.text != "" {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
            self.tableView.reloadData();
        }
        navigationController?.popViewController(animated:true)
    }
    
    //labels & fields
    var nameLabel: UILabel?
    var symbolLabel: UILabel?
    var currOwnedField: UILabel?
    var totalValueField: UILabel?
    var totalSpentField: UILabel?
    var selectedDateLabel: UILabel?
    
    var dateField: UIDatePicker?
    var textField: UITextField?
    
    //input variables
    var inputStock: Stock?
    
    //coreData variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //used for checking if a date is a calendar
    var tempCalendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    // MARK: - Table view data source
    // number of rows per section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 4
        }
        else if (section == 1) {
            return 4
        }
        else if (section == 2) {
            return 4
        }
        else {
            return 0
        }
    }
    
    // number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // titles per section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return inputStock?.stockName
        }
        else if (section == 1) {
            return "Your Stocks"
        }
        else if (section == 2) {
            return "Required Selections"
        }
        else {
            return "Error, this shouldn't be loaded"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        if (indexPath.section == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "LeftRightItem", for: indexPath)
            
            let leftLabel = cell?.viewWithTag(10) as! UILabel
            let rightLabel = cell?.viewWithTag(20) as! UILabel
            
            switch indexPath.row {
            case 0:
                leftLabel.text = inputStock?.stockName
                rightLabel.text = inputStock?.stockSymbol
            case 1:
                leftLabel.text = "Exchange"
                rightLabel.text = inputStock?.exchange
            case 2:
                leftLabel.text = "Sector"
                rightLabel.text = inputStock?.sector
            case 3:
                leftLabel.text = "Industry"
                rightLabel.text = inputStock?.industry
            default:
                return UITableViewCell()
            }
        }
        else if (indexPath.section == 1) {
            switch indexPath.row {
            case 0:
                let ownedCell = tableView.dequeueReusableCell(withIdentifier: "CurrOwnedItem", for: indexPath)
                currOwnedField = ownedCell.viewWithTag(3001) as? UILabel
                currOwnedField?.text = inputStock?.amountOwned.description
                
                cell = ownedCell
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "LeftRightItem", for: indexPath)
                
                let leftLabel = cell?.viewWithTag(10) as! UILabel
                let rightLabel = cell?.viewWithTag(20) as! UILabel
                
                leftLabel.text = "Current Value:"
                rightLabel.text = floatToCurrency(inputStock!.totalValue/Float(inputStock!.amountOwned))
            case 2:
                let totalSpentCell = tableView.dequeueReusableCell(withIdentifier: "TotalSpentItem", for: indexPath)
                totalSpentField = totalSpentCell.viewWithTag(5001) as? UILabel
                //totalSpentField?.text = String(format: "%.2f", inputStock!.totalSpent)
                totalSpentField?.text = floatToCurrency(inputStock!.totalSpent)
                
                cell = totalSpentCell
            case 3:
                let totalValueCell = tableView.dequeueReusableCell(withIdentifier: "TotalValueItem", for: indexPath)
                totalValueField = totalValueCell.viewWithTag(4001) as? UILabel
                //totalValueField?.text = String(format: "%.2f", inputStock!.totalValue)
                totalValueField?.text = floatToCurrency(inputStock!.totalValue)
                
                cell = totalValueCell
            default:
                cell = nil
            }
        }
            
        else {
            switch indexPath.row {
                
            case 0:
                let lastModifiedCell = tableView.dequeueReusableCell(withIdentifier: "LeftRightItem", for: indexPath)
                let leftLabel = lastModifiedCell.viewWithTag(10) as! UILabel
                let rightLabel = lastModifiedCell.viewWithTag(20) as! UILabel
                
                leftLabel.text = "Last Modified: "
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                rightLabel.text = formatter.string(from: (inputStock?.lastTraded)!)
                
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
                textField = textCell.viewWithTag(234) as? UITextField
                textField?.addTarget(self, action: #selector(OptionsViewController.textFieldDidChange(_:)), for: .editingChanged)
                
                cell = textCell
            default:
                cell = nil
            }
        }
        
        return cell ?? UITableViewCell()
    }
    
    // system version is from stackOverflow
    // source: https://stackoverflow.com/questions/24503001/check-os-version-in-swift
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 && indexPath.section == 2 {
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
    
    // when selecting outside, don't highlight
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath.section == 2 && indexPath.row == 2) {
            self.performSegue(withIdentifier: "sellingDatePricePickerSegue", sender: self)
            return indexPath
        }
        return nil
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSellingConfirmation" {
            let controller = segue.destination as! SellingConfirmationTableViewController
            selectedDate = dateField?.date
            controller.inputDate = selectedDate
            controller.inputStock = self.inputStock
            controller.inputNumSold = textField?.text
        }
        else if segue.identifier == "sellingDatePricePickerSegue" {
            let controller = segue.destination as! DatePricePickerTableViewController
            controller.delegate = self
            controller.inputSymbol = self.inputStock!.stockSymbol
        }
    }
    
    // makes the textField show up immediately
    // idea of dispatching was from stackoverflow
    // source: https://stackoverflow.com/questions/25353687/swift-become-first-responder-on-uitextfield-not-working
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.textField?.becomeFirstResponder()
        }
    }
    
    // MARK:- Actions
    // alert code was taken an modified from a website
    // source:https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
    @IBAction func pressedConfirmButton(_ sender: Any) {
        if (Int64((textField?.text)!)! > inputStock!.amountOwned) {
            let alert = UIAlertController(title: "Improper input", message: "You chose to sell more than you own of this stock. This is not allowed ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else {
            let status: Int = dateField?.date.isValidDate((inputStock?.stockSymbol!)!, inputDate: dateField!.date) ?? -10
            if(status == 1) {
                performSegue(withIdentifier: "toSellingConfirmation", sender: self)
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
    }
    
    // MARK:- Text Field Delegate
    // filters what comes into the textField
    //source: https://medium.com/mobile-app-development-publication/making-ios-uitextfield-accept-number-only-4e9f569ae0c6
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return (string.rangeOfCharacter(from: invalidCharacters) == nil)
    }
    
    // checks if the textField changes and if it is empty
    // source: https://stackoverflow.com/questions/28394933/how-do-i-check-when-a-uitextfield-changes
    @objc func textFieldDidChange(_ textField: UITextField) {
        if self.textField?.text != "" {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}
