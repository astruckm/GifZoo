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
            
    // FIXME: this var is now deprecated
    var queryParameterKeys: [String] {
        switch self {
        case .search: return ["q", "limit", "offset", "rating", "lang"]
        case .translate: return ["s"]
        case .trending: return ["limit", "rating"]
        case .random: return ["tag", "rating"]
        }
    }
    
    var queryParameterKeyStringsByType: [QueryKeyType: String] {
        switch self {
        case .search: return [.searchQuery: "q", .limit: "limit", .offset: "offset", .rating: "rating", .language: "lang"]
        case .translate: return [.searchQuery: "s"]
        case .trending: return [.limit: "limit", .rating: "rating"]
        case .random: return [.searchQuery: "tag", .rating: "rating"]
        }
    }
    
    enum Rating: String {
        case g = "g"
        case pg = "pg"
        case pg13 = "pg-13"
        case r = "r"
    }
}

enum QueryKeyType: String, Hashable, CaseIterable {
    case searchQuery, limit, offset, rating, language
    
}

