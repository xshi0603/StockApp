//
//  SearchResult.swift
//  StocksApp
//
//  Created by Xing on 11/24/20.
//  Copyright © 2020 Xing. All rights reserved.
//

import Foundation

class ResultArray: Codable {
    var bestMatches = [SearchResult]()
}

class SearchResult: Codable, CustomStringConvertible {
    var symbol: String? = ""
    var name: String? = ""
    
    var description: String {
        return "Symbol: \(symbol ?? "None"), Stock Name: \(name ?? "None")"
    }
    
    //custom keys was from a stackOverflow post
    //source:https://stackoverflow.com/questions/44396500/how-do-i-use-custom-keys-with-swift-4s-decodable-protocol
    private enum CodingKeys : String, CodingKey {
        case symbol = "1. symbol", name = "2. name"
    }
}
