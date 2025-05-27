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
    
    private let disposeBag: DisposeBag = .init()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.width / 2
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .red
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        contentView.backgroundColor = UIColor(hex: "#EFEFEF")
        
        contentView.addSubview(avatarImageView)
        avatarImageView.pin.left(16)
            .vCenter()
        
        contentView.addSubview(usernameLabel)
        usernameLabel.pin
            .left(to: avatarImageView.edge.right)
            .marginLeft(12)
            .vCenter()
    }
    
    func configure(with imageURL: String, username: String){
        
        usernameLabel.text = username
        
        guard let url = URL(string: imageURL) else {
            avatarImageView.image = UIImage(named: "nilImage")
            return
        }
        
        let networkService = NetworkService(baseURL: url)
        
        struct ImageEndpoint: Endpoint {
            public let path = ""
            public let method = "GET"
            public let queryItems: [URLQueryItem]? = nil
            public let headers: [String: String]? = nil
            public let body: Data? = nil
            
            public init() {}
        }
        
        let endpoint: Endpoint = ImageEndpoint()
        
        networkService.downloadImage(from: endpoint)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] image in
                self?.avatarImageView.image = image
            }, onFailure: { error in
                print("Ошибка загрузки изображения: \(error)")
            })
            .disposed(by: disposeBag)
        
    }
    
}

