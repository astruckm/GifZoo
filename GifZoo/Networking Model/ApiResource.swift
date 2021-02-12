//
//  ApiResource.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 2/12/21.
//

import Foundation


protocol ApiResource {
    associatedtype ModelType: Decodable
    var endpoint: String { get }
    func constructURL(forEndpoint endpoint: String, withQueries queries: [String: String]) -> URL?
}
