//
//  NetworkingErrors.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 2/14/21.
//

import Foundation

enum NetworkingErrors: String, Error {
    case noData = "Data from request is nil"
    case noImageData = "Image data could not be retrieved from URL"
    case dataDecodingFailure = "Could not decode JSON data to data model type"
    case noImageURL = "No url for that image"
    case makeGifFailure = "Could not create gif from the image data"
}
