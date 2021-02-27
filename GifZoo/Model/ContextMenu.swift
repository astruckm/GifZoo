//
//  ContextMenu.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 2/25/21.
//

import UIKit


protocol ContextMenu {
    func save(_ gif: Gif)
    func search(_ gif: Gif)
    func share(_ gif: Gif)
}

extension ContextMenu {
    func saveGifAction(_ gif: Gif) -> UIAction {
        return UIAction(title: NSLocalizedString("Save URL", comment: ""), image: UIImage(systemName: "square.and.arrow.down.on.square"), discoverabilityTitle: "Saves the URL for the gif so you can access it again.") { (action) in
            self.save(gif)
        }
    }
    
    func searchGifsAction(_ gif: Gif) -> UIAction {
        return UIAction(title: NSLocalizedString("Search Similar Gifs", comment: ""), image: UIImage(systemName: "magnifyingglass"), discoverabilityTitle: "Start a new search based on this Gif's title.") { (action) in
            self.search(gif)
        }
    }
    
    func shareGifsAction(_ gif: Gif) -> UIAction {
        return UIAction(title: NSLocalizedString("Share Gif", comment: ""), image: UIImage(systemName: "square.and.arrow.up"), discoverabilityTitle: "Share this Gif through another app.") { (action) in
            self.share(gif)
        }
    }
}
