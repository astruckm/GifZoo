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

