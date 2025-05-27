//
//  ViewController.swift
//  RickMasters
//
//  Created by Алексей Румынин on 25.05.25.
//

import UIKit
import PinLayout

public final class StatisticViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont.gilroyExtraBold(ofSize: 32)
        label.textColor = UIColor(hex: "#2D2D2DFF")
        return label
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section,SectionItem>! = nil
    private var collectionView: UICollectionView! = nil
    
    private var sections: [Section] = []
    
    private var mockSections: [Section] {
        
        let visortBoolItems: [SectionItem] = [
            SectionItem.visitor(VisitorSection(isUp: true, numberOfVisitors: 1356, description:"Количество посетителей в этом месяце выросло")),
            
        ]
        
        let sections: [Section] = [
            
            Section(type: .visitors, items: visortBoolItems)
            
        ]
        
        return sections
        
    }
    
    private let statisticService = StatisticService()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F6F6F6FF")
            statisticService.fetchUsers()
            setupCollectionView()
            createDataSource()
            dispayData()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupView()
    }
    
//    public override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        setupCollectionView()
//        createDataSource()
//        dispayData()
//    }
    
    private func dispayData(){
        DispatchQueue.main.async {
            self.collectionView.setCollectionViewLayout(self.createCompostionalLayout(with: self.mockSections), animated: false)
            self.createDataSource()
            self.reloadData(with: self.mockSections)
        }
    }
    
    private func setupView(){
        
//        view.addSubview(titleLabel)
        
//        let safeTop = view.safeAreaInsets.top
//        
//        view.addSubview(titleLabel)
//        titleLabel.pin
//            .top(safeTop + 48)
//            .horizontally(16)
//            .sizeToFit()
        
        view.addSubview(collectionView)
        collectionView.pin.left().right().top().bottom()
        
        
    }
    
    private func setupCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(hex: "#F6F6F6")
        collectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionView)
        collectionView.register(BoolCell.self, forCellWithReuseIdentifier: BoolCell.identifire)
        collectionView.register(VisitorCell.self, forCellWithReuseIdentifier: VisitorCell.identifire)
        
    }
    
    private func createDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Section,SectionItem>(
            collectionView: collectionView,
            cellProvider: { (collectionView,IndexPath,item) -> UICollectionViewCell? in
                
                switch item {
                case .mostVisited(let mostVisited):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisitorCell.identifire, for: IndexPath) as? VisitorCell
                    cell?.configure(with: mostVisited.imageUrl, username: mostVisited.username)
                    return cell
                case .visitor(let visitor):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoolCell.identifire, for: IndexPath) as? BoolCell
                    cell?.configure(isUP: visitor.isUp, number: visitor.numberOfVisitors, description: visitor.description)
                    return cell
                case .sexAge(let sexAge):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SexAgeCell.identifire, for: IndexPath) as? SexAgeCell
                    return cell
                case .observers(let observer):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisitorCell.identifire, for: IndexPath) as? VisitorCell
                    return cell
                }
            }
        )
    }
    
    private func createCompostionalLayout(with section: [Section]) -> UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            let section = section[sectionIndex]
            switch section.type{
            case .visitors:
                return self.createVisitorSection()
            case .mostVisited:
                return self.createMostVisitedSection()
                // дадльще тест варик
            case .observers:
                return self.createMostVisitedSection()
            case .sexAge:
                return self.createMostVisitedSection()
            }
        }
        return layout
    }
    
    private func createMostVisitedSection() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 16)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(218))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        return section
    }
    
    private func createVisitorSection() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(130))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        return section
    }
    
    private func reloadData(with sections: [Section]) {
        print("Sections count:", sections.count)
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>()
        sections.forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
}

struct Section: Hashable{
    let type: TypeOfSection
    let items: [SectionItem]
}

enum TypeOfSection{
    case visitors
    case mostVisited
    case sexAge
    case observers
}

enum SectionItem: Hashable{
    case visitor(VisitorSection)
    case mostVisited(MostVisitedSection)
    case sexAge(SexAgeSection)
    case observers(ObserverSection)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .visitor(let visitor):
            hasher.combine(visitor.id)
        case .mostVisited(let visiter):
            hasher.combine(visiter.id)
        case .sexAge(let sexAge):
            hasher.combine(sexAge.id)
        case .observers(let observer):
            hasher.combine(observer.id)
        }
    }
}

struct VisitorSection:Hashable{
    let id = UUID()
    let isUp: Bool
    let numberOfVisitors: Int
    let description: String
}

struct MostVisitedSection:Hashable{
    let id = UUID()
    let imageUrl: String
    let username: String
}

struct SexAgeSection:Hashable{
    let id = UUID()
    let users: [User]
}

struct ObserverSection:Hashable{
    let id = UUID()
    let visitors: [VisitorSection]
}
