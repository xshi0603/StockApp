//
//  AppStoreReviewManager.swift
//  StocksApp
//
//  Created by Xing on 12/6/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import Foundation
import StoreKit

// reviewing was from an external source
// source:https://www.raywenderlich.com/9009-requesting-app-ratings-and-reviews-tutorial-for-ios
enum AppStoreReviewManager {
  static func requestReviewIfAppropriate() {
    SKStoreReviewController.requestReview()
  }
}
