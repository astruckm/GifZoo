//
//  MP4ContainerView.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 2/25/21.
//

import UIKit

class MP4ContainerView: UIView {
    let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Verdana", size: 18)
        label.textColor = UIColor(red: 5/255, green: 142/255, blue: 217/255, alpha: 1.0)
        
        label.backgroundColor = .clear
        
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    let gifContainer: UIView = {
        let view = UIView()
        
        return view
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .white
        
    }
    
    
    private func setupSubviews() {
        addSubviewConstraints()
    }
    
    private func addSubviewConstraints() {
        addSubview(title)
        
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75),
            title.topAnchor.constraint(equalTo: topAnchor),
            title.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    internal func bringSubviewsToFront() {
        bringSubviewToFront(title)
    }
    
    // TODO: add any subviews: MP4View, "X" to close, save URL to favorites button
}
