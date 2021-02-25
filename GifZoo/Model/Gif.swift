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
    
    init(metadata: GifSize?, title: String) {
        self.metadata = metadata
        
        if let gifLiteralRange = title.range(of: "GIF by") {
            let fullRange: Range<String.Index> = gifLiteralRange.lowerBound..<title.endIndex
            var mutableTitle = title
            mutableTitle.replaceSubrange(fullRange, with: "")
            self.title = mutableTitle
        } else {
            self.title = title
        }        
    }
}

extension Gif: Equatable {
    static func == (lhs: Gif, rhs: Gif) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}


