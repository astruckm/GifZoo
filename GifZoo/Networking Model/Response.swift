//
//  Response.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 12/14/20.
//

import Foundation



struct Response {
    struct GifsResponse: Decodable {
        let data: [ResponseData]?
    }

    struct RandomGifResponse: Decodable {
        let data: ResponseData?
    }
}

struct ResponseData: Decodable {
    let id: String?
    let title: String?
    let images: GifSize?
}

struct GifSize: Decodable, Hashable {
    let fixedHeightSmall: GifMetadata?
    let fixedWidthSmall: GifMetadata?
    let mp4: GifMetadata?
    
    enum CodingKeys: String, CodingKey {
        case fixedHeightSmall = "fixed_height_small"
        case fixedWidthSmall = "fixed_width_small"
        case mp4 = "original_mp4"
    }
}

struct GifMetadata: Decodable, Hashable {
    let height: String?
    let width: String?
    let mp4_size: String?
    let size: String?
    
    let mp4: String?
    let url: String?
}



