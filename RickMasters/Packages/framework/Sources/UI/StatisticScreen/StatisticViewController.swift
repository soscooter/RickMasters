//
//  ViewController.swift
//  RickMasters
//
//  Created by Алексей Румынин on 25.05.25.
//

import UIKit
import PinLayout
import RxSwift

public final class StatisticViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let apiClient = APIClient()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont.gilroyExtraBold(ofSize: 32)
        label.textColor = UIColor(hex: "#2D2D2DFF")
        return label
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section,SectionItem>! = nil
    private var collectionView: UICollectionView! = nil
    
    let refreshControl = UIRefreshControl()
    
    private var sections: [Section] = []
    
    private var mostVisitedItems: [SectionItem] = []
    
    let visortBoolItems: [SectionItem] = [
        SectionItem.visitor(VisitorSection(isUp: true, numberOfVisitors: 1356, description:"Количество посетителей в этом месяце выросло")),
    ]
    
    let observerBoolItems: [SectionItem] = [
        SectionItem.observers(VisitorSection(isUp: true, numberOfVisitors: 1356, description:"Новые наблюдатели в этом месяце")),
        SectionItem.observers(VisitorSection(isUp: false, numberOfVisitors: 10, description:"Пользователей перестали за Вами наблюдать"))
    ]
    
    let segmentItems: [SectionItem] = [
        SectionItem.segmentView(Segments(segments: ["По дням", "По неделям", "По месяцам"]))
    ]
    
    let SexAgesegmentItems: [SectionItem] = [
        SectionItem.segmentView(Segments(segments: ["Сегодня", "Неделя", "Месяц", "Все время"]))
    ]
    
    var VisitorStatistictems: [SectionItem] = []

    private func makeSections() -> [Section] {
        let sections: [Section] = [
            
            Section(type: .visitors, items: visortBoolItems),
            Section(type: .segment, items: segmentItems),
            Section(type: .visitorStatistic, items: VisitorStatistictems),
            Section(type: .mostVisited, items: mostVisitedItems),
            Section(type: .sexAgeSegment, items: SexAgesegmentItems),
            Section(type: .observers, items: observerBoolItems),
            
        ]
        
        return sections
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F6F6F6FF")
        
        setupCollectionView()
        createDataSource()
        
        updateUsers()
        updateStatistics()
    }
    
    @objc
    private func updateData(){
        updateUsers()
        updateStatistics()
        refreshControl.endRefreshing()
    }
    
    private func updateStatistics() {
        struct GetStatisticRequest: APIRequest {
            var method: RequestType { return .GET }
            var path: String { return "statistics" }
            var parameters: [String: String] {
                return [:]
            }
        }
        
        let request = GetStatisticRequest()
        
        apiClient.send(apiRequest: request)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (response: StatisticResponse) in
                    print("Получена статистика: \(response.statistics)")
                    self?.VisitorStatistictems = [
                        SectionItem.visitorStatistic(visitorStatisticSection(statistic: response.statistics))
                    ]
//                    self?.dispayData()
                },
                onError: { error in
                    print("Ошибка: \(error.localizedDescription)")
                    if let decodingError = error as? DecodingError {
                        print("Детальная ошибка декодирования: \(decodingError)")
                    }
                }
            )
            .disposed(by: disposeBag)
    }
    
   private func updateUsers() {
        struct GetUsersRequest: APIRequest {
            var method: RequestType { return .GET }
            var path: String { return "users" }
            var parameters: [String: String] {
                return [:]
            }
        }
        
        let request = GetUsersRequest()
        
        apiClient.send(apiRequest: request)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (response: UsersResponse) in
                    print("Получены пользователи: \(response.users)")
                    var items: [SectionItem] = []
                    response.users.forEach({ user in
                        items.append(SectionItem.mostVisited(MostVisitedSection(imageUrl: user.files.first!.url, username: user.username)))
                    })
                    self?.mostVisitedItems = items
                    self?.dispayData()
                },
                onError: { error in
                    print("Ошибка: \(error.localizedDescription)")
                    if let decodingError = error as? DecodingError {
                        print("Детальная ошибка декодирования: \(decodingError)")
                    }
                }
            )
            .disposed(by: disposeBag)
    }
    
    
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func dispayData(){
        
        guard mostVisitedItems != [] || visortBoolItems != [] || observerBoolItems != [] else { return }
        
        DispatchQueue.main.async {
            self.collectionView.setCollectionViewLayout(self.createCompostionalLayout(with: self.makeSections()), animated: false)
            self.createDataSource()
            self.reloadData(with: self.makeSections())
        }
    }
    
    private func setupCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(hex: "#F6F6F6")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        view.addSubview(collectionView)
        collectionView.register(BoolCell.self, forCellWithReuseIdentifier: BoolCell.identifire)
        collectionView.register(VisitorCell.self, forCellWithReuseIdentifier: VisitorCell.identifire)
        collectionView.register(SegmentControlCell.self, forCellWithReuseIdentifier: SegmentControlCell.identifire)
        collectionView.register(VisiterStaticticCell.self, forCellWithReuseIdentifier: VisiterStaticticCell.identifire)
        
        collectionView.register(SectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeaderView.reuseIdentifier)
    }
    
    private func createDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Section,SectionItem>(
            collectionView: collectionView,
            cellProvider: { (collectionView,IndexPath,item) -> UICollectionViewCell? in
                
                switch item {
                case .mostVisited(let mostVisited):
                    let section = self.dataSource.snapshot().sectionIdentifiers[IndexPath.section]
                    let items = self.dataSource.snapshot().itemIdentifiers(inSection: section)
                    let isLast = (IndexPath.item == items.count - 1)
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisitorCell.identifire, for: IndexPath) as? VisitorCell
                    cell?.configure(with: mostVisited.imageUrl, username: mostVisited.username, isLast: isLast)
                    return cell
                case .visitor(let visitor):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoolCell.identifire, for: IndexPath) as? BoolCell
                    cell?.configure(isUP: visitor.isUp, number: visitor.numberOfVisitors, description: visitor.description, isLast: false)
                    return cell
                case .visitorStatistic(let visitorStatistic):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisiterStaticticCell.identifire, for: IndexPath) as? VisiterStaticticCell
                    cell?.configure(with: visitorStatistic.statistic)
                    return cell
                case .observers(let observer):
                    let section = self.dataSource.snapshot().sectionIdentifiers[IndexPath.section]
                    let items = self.dataSource.snapshot().itemIdentifiers(inSection: section)
                    let isLast = (IndexPath.item == items.count - 1)
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoolCell.identifire, for: IndexPath) as? BoolCell
                    cell?.configure(isUP: observer.isUp, number: observer.numberOfVisitors, description: observer.description, isLast: isLast)
                    return cell
                case .segmentView(let segment), .sexAgeSegmentView(let segment):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SegmentControlCell.identifire, for: IndexPath) as? SegmentControlCell
                    cell?.configure(with: segment.segments)
                    return cell

                }
            }
        )
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as? SectionHeaderView
            
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            let title: String
            switch section.type {
            case .visitors:
                title = "Посетители"
            case .mostVisited:
                title = "Чаще всех посещают Ваш профиль"
            case .observers:
                title = "Наблюдатели"
            case .sexAgeSegment:
                title = "Пол и возраст"
            default: title = ""
            }
            
            header?.configure(with: title)
            return header
        }
    }
    
    private func createCompostionalLayout(with section: [Section]) -> UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            let section = section[sectionIndex]
            switch section.type{
            case .visitors:
                return self.createVisitorSection()
            case .mostVisited:
                return self.createMostVisitedSection()
            case .observers:
                return self.createObserversSection()
            case .visitorStatistic:
                return self.createSexAgeSection()
            case .segment:
                return self.createSegmentSection()
            case .sexAgeSegment:
                return self.createSexAgeSegmentSection()
            }
        }
        layout.register(RoundedBackgroundView.self, forDecorationViewOfKind: RoundedBackgroundView.reuseIdentifier)
        
        return layout
    }
    
    private func createSexAgeSection() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(208))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func createSexAgeSegmentSection() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(32))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 16, trailing: 16)
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(24)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        return section
    }
    
    private func createSegmentSection() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(32))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func createMostVisitedSection() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(62))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.decorationItems = [
            NSCollectionLayoutDecorationItem.background(elementKind: RoundedBackgroundView.reuseIdentifier)
        ]
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 16, trailing: 16)
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(24)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        return section
    }
    
    private func createVisitorSection() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(98))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.decorationItems = [
            NSCollectionLayoutDecorationItem.background(elementKind: RoundedBackgroundView.reuseIdentifier)
        ]
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(24)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        return section
    }
    
    private func createObserversSection() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(98))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.decorationItems = [
            NSCollectionLayoutDecorationItem.background(elementKind: RoundedBackgroundView.reuseIdentifier)
        ]
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(24)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
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

class RoundedBackgroundView: UICollectionReusableView {
    
    private var insetView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(insetView)
        insetView.pin
            .left(16)
            .right(16)
            .top(36)
            .bottom(16)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

class SectionHeaderView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.gilroyExtraBold(ofSize: 20)
        label.textColor = UIColor(hex: "#000000")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.pin
            .bottom()
            .right()
            .left()
            .top()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
