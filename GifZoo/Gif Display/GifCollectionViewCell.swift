//
//  GifCollectionViewCell.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 12/14/20.
//

import UIKit

class GifCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(withImage image: UIImage?) {
        imageView.image = image
        imageView.startAnimating()
    }
    
}
