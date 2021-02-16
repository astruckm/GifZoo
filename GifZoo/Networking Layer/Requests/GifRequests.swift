//
//  GifRequests.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 2/13/21.
//

import UIKit
import AVFoundation


class GifRequest: NetworkRequest {
    typealias ModelType = UIImage
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func load(withCompletion completion: @escaping (Result<UIImage, Error>) -> ()) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.load(self.url, withCompletion: completion)
        }
    }
    
    func decode(_ data: Data) -> UIImage? {
        return UIImage.gifImageWithData(data)
    }
}

class MP4Request: NetworkRequest {
    typealias ModelType = AVPlayerItem
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func load(withCompletion completion: @escaping (Result<AVPlayerItem, Error>) -> ()) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            let mp4Item = AVPlayerItem(url: self.url)
            if let itemError = mp4Item.error {
                print("Error fetching mp4 from url: \(itemError)")
                completion(.failure(itemError))
                return
            }
            completion(.success(mp4Item))
        }
        
    }
    
    func decode(_ data: Data) -> AVPlayerItem? {
        return nil
    }
}

class GiphyRequest: NetworkRequest {
    typealias ModelType = GiphyResponse
    var endpoint: GiphyEndpoint
    var term: String
    var limit: Int?
    var offset: Int?
    var rating: GiphyEndpoint.Rating?
    var language: Locale?
    var url: URL? {
        return constructURLWithQueries(searchTerm: term, limit: limit, offset: offset, rating: rating, language: language?.identifier)
    }
    
    init(endpoint: GiphyEndpoint, searchTerm term: String = "", limit: Int? = nil, offset: Int? = 0, rating: GiphyEndpoint.Rating? = .g, language: String? = "en") {
        self.endpoint = endpoint
        self.term = term
        self.limit = limit
        self.offset = offset
        self.rating = rating
        self.language = Locale(identifier: language ?? "")
    }
    
    private func constructURLWithQueries(searchTerm term: String? = nil, limit: Int? = nil, offset: Int? = nil, rating: GiphyEndpoint.Rating? = nil, language: String? = nil) -> URL? {
        var queries: [String: String] = [:]
        
        for keyType in QueryKeyType.allCases {
            let key = self.endpoint.queryParameterKeyStringsByType[keyType]
            if let key = key {
                var value: String? = nil
                switch keyType {
                case .searchQuery: value = term
                case .limit:
                    if let limit = limit {
                        value = String(limit)
                    }
                case .offset:
                    if let offset = offset {
                        value = String(offset)
                    }
                case .rating: value = rating?.rawValue
                case .language: value = language
                }
                queries[key] = value
            }
        }
        
        return constructURL(withQueries: queries)
    }
    
    private func constructURL(withQueries queries: [String : String]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.giphy.com"
        components.path = "/v1/gifs/" + endpoint.rawValue
        
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        queryItems.append(contentsOf: queries.map { URLQueryItem(name: $0.key, value: $0.value) })
        components.queryItems = queryItems
        
        return components.url
    }
    
    func load(withCompletion completion: @escaping (Result<GiphyResponse, Error>) -> ()) {
        guard let url = url else { return }
        load(url, withCompletion: completion)
    }
    
    func decode(_ data: Data) -> GiphyResponse? {
        let decoder = JSONDecoder()
        let endpointIsRandom = endpoint == .random
        if endpointIsRandom {
            let jsonData = try? decoder.decode(RandomGifResponse.self, from: data)
            return jsonData
        } else {
            let jsonData = try? decoder.decode(GifsResponse.self, from: data)
            return jsonData
        }
    }

}

