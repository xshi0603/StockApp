//
//  Helpers.swift
//  StocksApp
//
//  Created by Xing on 12/10/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import Foundation

func floatToCurrency(_ inputDouble: Float) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    let inputNumber = NSNumber(value:inputDouble)
    if let formattedTipAmount = formatter.string(from: inputNumber as NSNumber) {
        return(formattedTipAmount)
    }
    return("")
}

func errorParse(data: Data) -> String {
    do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(ErrorResultArray.self, from:data)
        return result.Note
    } catch {
        return "JSON Error (kinda not really)"
    }
}
