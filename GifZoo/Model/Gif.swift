//
//  Gif.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 12/15/20.
//

import UIKit


struct Gif: Hashable {
    let metadata: GifSize?
    let id = UUID()
    let title: String
}

extension Gif: Equatable {
    static func == (lhs: Gif, rhs: Gif) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}


