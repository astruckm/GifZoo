//
//  MP4ContainerView.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 2/25/21.
//

import UIKit

class MP4ContainerView: UIView {
    private let minHeaderHeight: CGFloat = 24
    private let minFooterHeight: CGFloat = 16
    private var headerHeight: CGFloat = 0
    private var footerHeight: CGFloat = 0
    
    // MARK: Define subviews
    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Verdana", size: 14)
        label.textAlignment = .center
        label.textColor = UIColor(red: 5/255, green: 142/255, blue: 217/255, alpha: 1)
        
        label.backgroundColor = .clear
        
        return label
    }()
        
    let gifContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.down.on.square"), for: .normal)
        
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        
        return button
    }()
    
    // MARK: Init and setup
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setup()
        setupSubviews()
    }
    
    private func setup() {
        backgroundColor = .white
//        headerHeight = bounds.height * 0.1
    }
    
    private func setupSubviews() {
        addSubviews()
    }
    
    private func addSubviews() {
        addSubview(title)
        addSubview(gifContainer)
        addSubview(saveButton)
        addSubview(shareButton)
    }
    
    // MARK: show subviews after selection
    internal func displaySubviews() {
        bringSubviewsToFront()
        setSubviewFrames(withHeaderHeight: headerHeight, footerHeight: footerHeight)
    }
    
    private func bringSubviewsToFront() {
        bringSubviewToFront(title)
        bringSubviewToFront(gifContainer)
        bringSubviewToFront(saveButton)
        bringSubviewToFront(shareButton)
    }
    
    private func setSubviewFrames(withHeaderHeight headerHeight: CGFloat, footerHeight: CGFloat) {
        title.frame = CGRect(x: bounds.width * 0.125, y: 0, width: bounds.width * 0.75, height: headerHeight)
        
        gifContainer.frame = CGRect(x: 0, y: headerHeight, width: bounds.width, height: bounds.height - headerHeight - footerHeight)
        
        saveButton.frame = CGRect(x: bounds.width * 1/3, y: bounds.height - footerHeight, width: footerHeight, height: footerHeight)
        shareButton.frame = CGRect(x: bounds.width * 2/3, y: bounds.height - footerHeight, width: footerHeight, height: footerHeight)
    }
    
}

extension MP4ContainerView {
    internal func viewHeight(fromMP4Height mp4Height: CGFloat) -> CGFloat {
        let headerHeight = max(minHeaderHeight, mp4Height * 1/8)
        self.headerHeight = headerHeight
        let footerHeight = max(minFooterHeight, mp4Height * 1/8)
        self.footerHeight = footerHeight
        
        return mp4Height + headerHeight + footerHeight
    }
}


