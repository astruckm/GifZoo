//
//  GifRequests.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 2/13/21.
//

import UIKit
import AVFoundation


class GifRequest {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
}

extension GifRequest: NetworkRequest {
    typealias ModelType = UIImage

    func load(withCompletion completion: @escaping (Result<UIImage, Error>) -> ()) {
        load(url, withCompletion: completion)
    }
    
    func decode(_ data: Data) -> UIImage? {
        return UIImage.gifImageWithData(data)
    }
    
}
