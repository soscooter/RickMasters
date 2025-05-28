//
//  BoolCell.swift
//  framework
//
//  Created by Алексей Румынин on 26.05.25.
//

import UIKit
import PinLayout

class BoolCell: UICollectionViewCell {
    
    static let identifire: String = "BoolCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.gilroyExtraBold(ofSize: 20)
        label.numberOfLines = 1
        label.textColor = UIColor(hex: "#000000")
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.gilroyLight(ofSize: 15)
        label.numberOfLines = 2
        label.textColor = UIColor(hex: "#000000")?.withAlphaComponent(0.6)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let separator: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(hex: "#EFEFEF")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = UIColor(hex: "#FFFFFF")?.withAlphaComponent(0)
        
        contentView.addSubview(imageView)
        imageView.pin
            .vCenter()
            .left(20)
            .sizeToFit()
//            .width(95)
//            .height(50)
        
        contentView.addSubview(numberLabel)
        numberLabel.pin
            .left(to: imageView.edge.right)
            .marginLeft(16)
            .top(16)
            .sizeToFit()
        
        contentView.addSubview(arrowImageView)
        arrowImageView.pin
            .left(to: numberLabel.edge.right)
            .top(20)
            .width(16)
            .height(16)
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.pin
            .left(to: imageView.edge.right)
            .marginLeft(16)
            .top(to: numberLabel.edge.bottom)
            .marginTop(7)
            .right(20)
            .minHeight(40)
            .sizeToFit(.widthFlexible)
        
    }
    
    private func setupSeporator(){
        contentView.addSubview(separator)
        separator.pin
            .bottom().marginTop(1)
            .height(1)
            .width(100%)
    }
    
    func configure(isUP: Bool,number: Int,description: String,isLast: Bool){
        imageView.image = isUP ? UIImage.upImage : UIImage.downImage
        numberLabel.text = "\(number)"
        descriptionLabel.text = description
        arrowImageView.image = isUP ? UIImage.upArrow : UIImage.downArrow
        setupViews()
        if isLast{
            setupSeporator()
        }
    }
  
}
