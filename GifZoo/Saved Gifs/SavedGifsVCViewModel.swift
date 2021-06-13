//
//  SavedGifsVCViewModel.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 6/13/21.
//

import UIKit

class SavedGifsVCViewModel {
    enum Section {
        case main
    }
    
    var gifRefs: [GifRef] = []
    var dataController: DataController!
    
    init() {
        dataController = DataController {
            
        }
        if let gifRefs = dataController.loadGifRef() as? [GifRef] {
            self.gifRefs = gifRefs
            
        }
    }
}
