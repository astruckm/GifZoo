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

struct GiphyResource: ApiResource {
    typealias ModelType = GiphyResponse /// TODO: need to choose which sub-type this represents depdending on if it's .random endpoint or not
    let giphyEndpoint: GiphyEndpoint
    var endpoint: String { return giphyEndpoint.rawValue }
    
    func constructURL(forEndpoint endpoint: String, withQueries queries: [String : String]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.giphy.com"
        components.path = "/v1/gifs/" + endpoint
        
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        queryItems.append(contentsOf: queries.map { URLQueryItem(name: $0.key, value: $0.value) })
        components.queryItems = queryItems
        
        return components.url

    }

}
