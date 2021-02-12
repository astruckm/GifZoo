//
//  GifDisplayVCViewModel.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 12/14/20.
//

import UIKit
import AVFoundation

class GifDisplayVCViewModel: NSObject {
    enum Section {
        case main
    }
    
    var gifs: [Gif] = []
    var gifsRetrievedImages: [UUID: [GifMetadata: UIImage]] = [:]
    let fetcher = GiphyFetcher.sharedInstance
    let dispatchGroup = DispatchGroup()
    
    func getGifs(withText text: String, endpoint: GiphyEndpoint, limit: String = "1", completion: @escaping () -> ()) {
        let queries = [endpoint.queryParameterKeys[0]: text, endpoint.queryParameterKeys[1]: limit]
        fetcher.fetchGifsData(endpoint: endpoint.rawValue, queries: queries) { [weak self] (result) in
            guard let self = self else {
                print("Unable to capture self while fetching random gif")
                return
            }
            
            switch result {
            case .failure(let error):
                print("Error fetching random Gif: \(error.localizedDescription)")
            case .success(let gifsResponse):
                gifsResponse.data?.forEach({ (datum) in
                    self.dispatchGroup.enter()
                    if let imageURLString = datum.images?.fixedWidthSmall?.url, let imageURL = URL(string: imageURLString) {
                        let gif = Gif(metadata: GifSize(fixedHeightSmall: datum.images?.fixedHeightSmall, fixedWidthSmall: datum.images?.fixedWidthSmall, mp4: datum.images?.mp4), title: (datum.title)!)
                        self.gifs.append(gif)
                        self.getImage(atURL: imageURL, forID: gif.id, metadata: ((gif.metadata?.fixedHeightSmall ?? gif.metadata?.fixedWidthSmall) ?? gif.metadata?.mp4)!) {
                            completion()
                            self.dispatchGroup.leave()
                        }
                    }
                })
            }
            self.dispatchGroup.notify(queue: DispatchQueue.global(qos: .utility)) {
                // Some kine of notification can go here if needed
                print("Finished downloading all gifs")
            }
        }
    }
    
    func getRandomGif(atText text: String, completion: @escaping () -> ()) {
        gifs = []
        fetcher.fetchRandomGif(tag: text) { [weak self] (result) in
            guard let self = self else {
                print("Unable to capture self while fetching random gif")
                return
            }
            
            switch result {
            case .failure(let error):
                print("Error fetching random Gif: \(error.localizedDescription)")
            case .success(let randomGifResponse):
                if let imageURL = URL(string: (randomGifResponse.data?.images?.mp4?.mp4) ?? "") {
                    let gif = Gif(metadata: GifSize(fixedHeightSmall: randomGifResponse.data?.images?.fixedHeightSmall, fixedWidthSmall: randomGifResponse.data?.images?.fixedWidthSmall, mp4: randomGifResponse.data?.images?.mp4), title: (randomGifResponse.data?.title)!)
                    self.gifs.append(gif)
                    self.getMP4(atURL: imageURL, forID: gif.id) {
                        completion()
                    }
                    print("Getting gif image file at url: ", imageURL)
                } else {
                    print("Could not get url for image")
                }
            }
        }
    }
    
    func getImage(atURL url: URL, forID id: UUID, metadata: GifMetadata, completion: @escaping () -> ()) {
        fetcher.fetchImage(atURL: url) { [weak self] (result) in
            guard let self = self else {
                print("Unable to capture self while fetching image")
                return
            }
            switch result {
            case .failure(let error):
                print("Error fetching imagefile: ", error.localizedDescription)
            case .success(let image):
                if var imagesByMetadata = self.gifsRetrievedImages[id] {
                    imagesByMetadata[metadata] = image
                    self.gifsRetrievedImages[id] = imagesByMetadata
                } else {
                    self.gifsRetrievedImages[id] = [metadata: image]
                }
                
                print("assigned image of duration: \(image.duration) to data model object")
                completion()
            }
        }
    }
    
    var mp4Item: AVPlayerItem? = nil
    var mp4: AVPlayer? = nil
    
    func getMP4(atURL url: URL, forID id: UUID, completion: @escaping () -> ()) {
        fetcher.fetchMp4(atURL: url) { [weak self] (result) in
            guard let self = self else {
                print("Unable to capture self while fetching image")
                return
            }
            switch result {
            case .failure(let error):
                print("Error fetching mp4: ", error.localizedDescription)
            case .success(let playerItem):
                self.mp4Item = playerItem
                self.mp4 = AVPlayer(playerItem: self.mp4Item)
                completion()
                print("Assigned mp4Item to AVPlayerItem")
            }
        }
        
    }
    
    
}
