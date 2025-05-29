//
//  VisitorCell.swift
//  framework
//
//  Created by Алексей Румынин on 27.05.25.
//

import UIKit
import PinLayout
import RxSwift

class VisitorCell: UICollectionViewCell {
    
    static let identifire: String = "VisitorCell"
        
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.gilroyExtraBold(ofSize: 15)
        label.textColor = UIColor(hex: "#000000")
        label.numberOfLines = 1
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.chevronRight
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#EFEFEF")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(chevronImageView)
        contentView.addSubview(separatorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.pin
            .left(16)
            .top(12)
            .width(38)
            .height(38)
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        
        usernameLabel.pin
            .left(to: avatarImageView.edge.right).marginLeft(12)
            .vCenter()
            .sizeToFit(.widthFlexible)
        
        chevronImageView.pin
            .right(24)
            .vCenter()
            .height(9)
            .width(15)
            .sizeToFit()
    }
    
    private func setupSeporator(){
        separatorView.pin
            .bottom().marginTop(1)
            .height(1)
            .width(100%)
    }
    
    func configure(with imageURL: String, username: String, isLast: Bool){
        avatarImageView.downloaded(from: imageURL)
        usernameLabel.text = username
        !isLast ? setupSeporator() : ()
    }
}
