//
//  PastelessTextField.swift
//  StocksApp
//
//  Created by Xing on 12/6/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import UIKit

class PastelessTextField: UITextField {
    //makes it so that you cant paste into this textField
    //source: https://medium.com/mobile-app-development-publication/making-ios-uitextfield-accept-number-only-4e9f569ae0c6
    override func canPerformAction(
        _ action: Selector, withSender sender: Any?) -> Bool {
          return super.canPerformAction(action, withSender: sender)
          && (action == #selector(UIResponderStandardEditActions.cut)
          || action == #selector(UIResponderStandardEditActions.copy))
      }
}
