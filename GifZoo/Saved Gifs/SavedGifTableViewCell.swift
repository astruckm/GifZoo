//
//  SavedGifTableViewCell.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 6/13/21.
//

import UIKit

class SavedGifTableViewCell: UITableViewCell {

    @IBOutlet weak var gifTitle: UILabel!
    
    func configure(title: String?) {
        gifTitle.text = title
        gifTitle.textColor = .systemPink
    }
}
