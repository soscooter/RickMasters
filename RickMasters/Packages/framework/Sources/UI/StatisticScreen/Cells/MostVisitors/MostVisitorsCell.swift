//
//  MostVisitorsCell.swift
//  framework
//
//  Created by Алексей Румынин on 27.05.25.
//

import UIKit

//class MostVisitorsCell: UICollectionViewCell {
//    
//    static let identifire: String = "MostVisitorsCell"
//    
//    private lazy var collectionView: UICollectionView! = nil
//    
//    private let users: [User] = []
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupViews(){
//        collectionView = UICollectionView(frame: contentView.bounds, collectionViewLayout: UICollectionViewFlowLayout())
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.register(VisitorCell.self, forCellWithReuseIdentifier: VisitorCell.identifire)
//    }
//    
//}
//
//extension MostVisitorsCell: UICollectionViewDelegate, UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        users.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return collectionView.dequeueReusableCell(withReuseIdentifier: VisitorCell.self, for: indexPath)
//    }
//    
//    
//}
