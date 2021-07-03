//
//  GifDisplayVCViewModel.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 12/14/20.
//

import UIKit
import AVFoundation
import CoreData

class GifDisplayVCViewModel {
    enum Section {
        case main
    }
    
    let dispatchGroup = DispatchGroup()
    var gifs: [Gif] = []
    var gifsRetrievedImages: [UUID: [GifMetadata: UIImage]] = [:]
    var mp4Item: AVPlayerItem? = nil
    var mp4: AVPlayer? = nil
    var cachedRequests: [AnyObject] = [] ///Just temporarily cache requests so ARC doesn't release GifRequests
    var cachedRequest: AnyObject?
    var dataController: DataController!
    
    init() {
        dataController = DataController { }
    }
    
    func getGifs(withText text: String, endpoint: GiphyEndpoint, limit: Int = 1, completion: @escaping () -> ()) {
        let request = GiphyRequest(endpoint: endpoint, searchTerm: text, limit: limit)
        cachedRequest = request
        request.load { [weak self] (result) in
            guard let self = self else {
                print("Unable to capture self while fetching random gif")
                return
            }
            
            switch result {
            case .failure(let error):
                print("Error fetching random Gif: \(error.localizedDescription)")
            case .success(let gifsResponse):
                guard let gifsResponse = gifsResponse as? GifsResponse else {
                    print("Could not cast GiphyResponse to RandomGifResponse")
                    return
                }
                gifsResponse.data.forEach({ (datum) in
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
            self.dispatchGroup.notify(queue: DispatchQueue.global(qos: .background)) {
                print("Finished downloading all gifs")
                self.cachedRequest = nil
                self.cachedRequests = []
            }
        }
    }
    
    func getRandomGif(atText text: String, completion: @escaping () -> ()) {
        gifs = []
        let request = GiphyRequest(endpoint: .random, searchTerm: text)
        cachedRequest = request
        request.load { [weak self] (result) in
            guard let self = self else {
                print("Unable to capture self while fetching random gif")
                return
            }
            
            switch result {
            case .failure(let error):
                print("Error fetching random Gif: \(error.localizedDescription)")
                self.cachedRequest = nil
            case .success(let randomGifResponse):
                guard let randomGifResponse = randomGifResponse as? RandomGifResponse else {
                    print("Could not cast GiphyResponse to RandomGifResponse")
                    return
                }
                if let imageURL = URL(string: (randomGifResponse.data.images?.mp4?.mp4) ?? "") {
                    let gif = Gif(metadata: GifSize(fixedHeightSmall: randomGifResponse.data.images?.fixedHeightSmall, fixedWidthSmall: randomGifResponse.data.images?.fixedWidthSmall, mp4: randomGifResponse.data.images?.mp4), title: (randomGifResponse.data.title)!)
                    self.gifs.append(gif)
                    self.cachedRequest = nil
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
        let gifRequest = GifRequest(url: url)
        cachedRequests.append(gifRequest)
        gifRequest.load { [weak self] (result) in
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
        
    func getMP4(atURL url: URL, forID id: UUID, completion: @escaping () -> ()) {
        let mp4Request = MP4Request(url: url)
        cachedRequest = mp4Request
        mp4Request.load { [weak self] (result) in
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
            self.cachedRequest = nil
        }
        
    }
    
    
}

