//
//  GiphyFetcher.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 12/14/20.
//

import UIKit
import AVFoundation


class GiphyFetcher: NSObject {
    static let sharedInstance = GiphyFetcher()
    
    private override init() {
        super.init()
    }
    
    private func constructURL(forEndpoint endpoint: String, withQueries queries: [String: String] = [:]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.giphy.com"
        components.path = "/v1/gifs/" + endpoint
        
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        queryItems.append(contentsOf: queries.map { URLQueryItem(name: $0.key, value: $0.value) })
        components.queryItems = queryItems
        
        return components.url
    }
    
    func fetchGifsData(endpoint: String, queries: [String: String], completion: @escaping (Result<GifsResponse, Error>) -> ()) {
        guard let url = constructURL(forEndpoint: endpoint, withQueries: queries) else {
            print("Could not construct URL for getGifsData")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkingErrors.noData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let jsonData = try decoder.decode(GifsResponse.self, from: data)
                completion(.success(jsonData))
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        })
        task.resume()
    }
    
    func fetchRandomGif(tag: String, completion: @escaping (Result<RandomGifResponse, Error>) -> ()) {
        guard let url = constructURL(forEndpoint: "random", withQueries: ["tag": tag, "rating": "g"]) else {
            print("Could not construct URL for getRandomGif")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkingErrors.noData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let jsonData = try decoder.decode(RandomGifResponse.self, from: data)
                completion(.success(jsonData))
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        })
        task.resume()
        
    }
    
    func fetchImage(atURL url: URL, completion: @escaping (Result<UIImage, Error>) -> ()) {
        DispatchQueue.global(qos: .background).async {
            do {
                let imageData = try Data(contentsOf: url)
                if let image = UIImage.gifImageWithData(imageData) {
                    completion(.success(image))
                } else {
                    completion(.failure(NetworkingErrors.noData))
                }
            } catch {
                completion(.failure(NetworkingErrors.noData))
            }
        }
    }
    
    func fetchMp4(atURL url: URL, completion: @escaping (Result<AVPlayerItem, Error>) -> ()) {
        DispatchQueue.global(qos: .userInteractive).async {
            let mp4Item = AVPlayerItem(url: url)
            if let itemError = mp4Item.error {
                print("Error fetching mp4 from url: \(itemError)")
                completion(.failure(itemError))
                return
            }
            completion(.success(mp4Item))
        }
    }
    
}




