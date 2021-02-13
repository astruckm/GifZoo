//
//  GiphyEndpoint.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 12/24/20.
//

import Foundation


enum GiphyEndpoint: String {
    case search
    case translate
    case trending
    case random
        
    var queryParameterKeys: [String] {
        switch self {
        case .search: return ["q", "limit", "offset", "rating", "lang"]
        case .translate: return ["s"]
        case .trending: return ["limit", "rating"]
        case .random: return ["tag", "rating"]
        }
    }
    
}
