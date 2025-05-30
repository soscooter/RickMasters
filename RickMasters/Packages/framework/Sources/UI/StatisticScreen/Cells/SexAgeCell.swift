//
//  SexAgeCell.swift
//  framework
//
//  Created by Алексей Румынин on 30.05.25.
//

import UIKit
import DGCharts
import PinLayout

class SexAgeCell: UICollectionViewCell {
    
    static let identifire = "SexAgeCell"
    
    private let pieChart = GenderPieChartView()
    private let legend = UIStackView()
    private let ageChart = AgeDistributionChartView()
    private let darkCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#FF2E00")
        return view
    }()
    private let lightCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F99963")
        return view
    }()
    
    
    private let maleLegend = UILabel()
    private let femaleLegend = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        setupViews()
        
        let mockMale = 40
        let mockFemale = 60
        configure(male: mockMale, female: mockFemale)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(pieChart)
        contentView.addSubview(legend)
        contentView.addSubview(ageChart)
        
        legend.axis = .horizontal
        legend.spacing = 16
        legend.alignment = .center
        
        maleLegend.text = "Мужчины 40%"
        maleLegend.font = UIFont.systemFont(ofSize: 13)
        maleLegend.textColor = UIColor.black
        maleLegend.textAlignment = .left
        
        femaleLegend.text = "Женщины 60%"
        femaleLegend.font = UIFont.systemFont(ofSize: 13)
        femaleLegend.textColor = UIColor.black
        femaleLegend.textAlignment = .right
        
        legend.addArrangedSubview(darkCircle)
        legend.addArrangedSubview(maleLegend)
        legend.addArrangedSubview(lightCircle)
        legend.addArrangedSubview(femaleLegend)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lightCircle.pin.width(10).height(10)
        darkCircle.pin.width(10).height(10)
        
        lightCircle.layer.cornerRadius = lightCircle.frame.width / 2
        darkCircle.layer.cornerRadius = darkCircle.frame.width / 2
        lightCircle.layer.masksToBounds = true
        darkCircle.layer.masksToBounds = true
        
        pieChart.backgroundColor = .white
        
        pieChart.pin.top(16).hCenter().size(151)
        legend.pin.horizontally(40)
        legend.pin.below(of: pieChart, aligned: .center).marginTop(8).height(20)
        ageChart.pin.below(of: legend).marginTop(8).horizontally(16).bottom(16)
    }
    
    func calculateAgeGroupStats(users: [User]) -> [AgeGroupStat] {
        let totalCount = users.count
        guard totalCount > 0 else { return [] }

        let ageGroups = [
            ("18–21", 18...21),
            ("22–25", 22...25),
            ("26–30", 26...30),
            ("31–35", 31...35),
            ("36–40", 36...40),
            ("40–50", 41...50),
            (">50", 51...150)
        ]

        var result: [AgeGroupStat] = []

        for (title, range) in ageGroups {
            let groupUsers = users.filter { range.contains($0.age) }
            let groupTotal = Double(groupUsers.count)
            guard groupTotal > 0 else {
                result.append(.init(ageGroup: title, malePercent: 0, femalePercent: 0))
                continue
            }

            let maleCount = Double(groupUsers.filter { $0.sex == .male }.count)
            let femaleCount = groupTotal - maleCount

            let malePercent = (maleCount / Double(totalCount)) * 100
            let femalePercent = (femaleCount / Double(totalCount)) * 100

            result.append(.init(ageGroup: title, malePercent: malePercent, femalePercent: femalePercent))
        }

        return result
    }
    
    func configure(male: Int, female: Int) {
        pieChart.configure(male: CGFloat(Int(Double(male))), female: CGFloat(Int(Double(female))))
        maleLegend.text = "Мужчины \(male)%"
        femaleLegend.text = "Женщины \(female)%"
        let users: [User] = [
            User(age: 20, sex: .male),
            User(age: 20, sex: .female),
            User(age: 23, sex: .male),
            User(age: 31, sex: .male),
            User(age: 35, sex: .female),
            User(age: 52, sex: .female),
            // ...другие пользователи
        ]

        let stats = calculateAgeGroupStats(users: users)
        ageChart.configure(with: stats)
    }
}

final class GenderPieChartView: UIView {
    
    private var femaleValue: CGFloat = 0
    private var maleValue: CGFloat = 0
    
    private let maleColor = UIColor(hex: "#FF2E00")
    private let femaleColor = UIColor(hex: "#FFAD8A")
    
    private let lineWidth: CGFloat = 6
    private let spacingAngle: CGFloat = .pi / 180 * 8
    
    func configure(male: CGFloat, female: CGFloat) {
        self.maleValue = male
        self.femaleValue = female
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard maleValue + femaleValue > 0 else { return }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(lineWidth)
        context?.setLineCap(.round)
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let total = maleValue + femaleValue
        
        let totalSpacing = spacingAngle * 2
        let availableAngle = 2 * .pi - totalSpacing
        
        let maleAngle = (maleValue / total) * availableAngle
        let femaleAngle = (femaleValue / total) * availableAngle
        
        let startAngleFemale = -CGFloat.pi / 2 + spacingAngle / 2
        let endAngleFemale = startAngleFemale + femaleAngle
        
        let startAngleMale = endAngleFemale + spacingAngle
        let endAngleMale = startAngleMale + maleAngle
        
        context?.setStrokeColor(femaleColor!.cgColor)
        let femalePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngleFemale, endAngle: endAngleFemale, clockwise: true)
        context?.addPath(femalePath.cgPath)
        context?.strokePath()
        
        context?.setStrokeColor(maleColor!.cgColor)
        let malePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngleMale, endAngle: endAngleMale, clockwise: true)
        context?.addPath(malePath.cgPath)
        context?.strokePath()
    }
}

final class AgeDistributionChartView: UIView {
    private var rows: [UIView] = []
    private let rowHeight: CGFloat = 45
    private let barMaxWidth: CGFloat = 200
    private let groupLabelWidth: CGFloat = 40
    private let minBarWidth: CGFloat = 8 // Минимальная ширина для отображения точки
    private let ageGroups = ["18–21", "22–25", "26–30", "31–35", "36–40", "40–50", ">50"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // Создаем строки для каждой возрастной группы
        for ageGroup in ageGroups {
            let rowView = UIView()
            addSubview(rowView)
            
            // Лейбл возрастной группы (слева)
            let groupLabel = UILabel()
            groupLabel.text = ageGroup
            groupLabel.font = UIFont.gilroyExtraBold(ofSize: 13)
            groupLabel.textColor = .black
            groupLabel.textAlignment = .right
            rowView.addSubview(groupLabel)
            
            // Контейнер для баров (справа от лейбла)
            let barsContainer = UIView()
            rowView.addSubview(barsContainer)
            
            rows.append(rowView)
        }
    }
    
    func configure(with stats: [AgeGroupStat]) {
        for (index, stat) in stats.enumerated() {
            guard index < rows.count else { break }
            
            let rowView = rows[index]
            let barsContainer = rowView.subviews[1] // 0 - groupLabel, 1 - barsContainer
            
            // Очищаем контейнер баров перед добавлением новых
            barsContainer.subviews.forEach { $0.removeFromSuperview() }
            
            // Мужской бар (оранжевый)
            let maleBar = UIView()
            maleBar.backgroundColor = UIColor(hex: "#FF2E00")
            maleBar.layer.cornerRadius = 4
            maleBar.layer.masksToBounds = true
            barsContainer.addSubview(maleBar)
            
            // Процент для мужчин (всегда показываем, даже 0%)
            let malePercent = UILabel()
            malePercent.text = "\(Int(round(stat.malePercent)))%"
            malePercent.font = UIFont.systemFont(ofSize: 10)
            malePercent.textColor = UIColor.black
            barsContainer.addSubview(malePercent)
            
            // Женский бар (светло-оранжевый)
            let femaleBar = UIView()
            femaleBar.backgroundColor = UIColor(hex: "#FFAD8A")
            femaleBar.layer.cornerRadius = 4
            femaleBar.layer.masksToBounds = true
            barsContainer.addSubview(femaleBar)
            
            // Процент для женщин (всегда показываем, даже 0%)
            let femalePercent = UILabel()
            femalePercent.text = "\(Int(round(stat.femalePercent)))%"
            femalePercent.font = UIFont.systemFont(ofSize: 10)
            femalePercent.textColor = UIColor.black
            barsContainer.addSubview(femalePercent)
            
            // Рассчитываем ширину баров (но не меньше minBarWidth)
            let maleWidth = max(minBarWidth, barMaxWidth * CGFloat(stat.malePercent / 100))
            let femaleWidth = max(minBarWidth, barMaxWidth * CGFloat(stat.femalePercent / 100))
            
            // Расположение элементов
            maleBar.pin
                .top(13)
                .left(30)
                .width(maleWidth)
                .height(8)
            
            malePercent.pin
                .after(of: maleBar)
                .marginLeft(4)
                .sizeToFit()
                .vCenter(to: maleBar.edge.vCenter)
            
            femaleBar.pin
                .below(of: maleBar)
                .marginTop(5)
                .left(30)
                .width(femaleWidth)
                .height(8)
            
            femalePercent.pin
                .after(of: femaleBar)
                .marginLeft(4)
                .sizeToFit()
                .vCenter(to: femaleBar.edge.vCenter)
            
            // Если процент равен 0, делаем бар круглой точкой
            if stat.malePercent == 0 {
                maleBar.pin.width(8).height(8)
                maleBar.layer.cornerRadius = 4
            }
            
            if stat.femalePercent == 0 {
                femaleBar.pin.width(8).height(8)
                femaleBar.layer.cornerRadius = 4
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Распределяем строки с фиксированными отступами
        for (index, row) in rows.enumerated() {
            let groupLabel = row.subviews[0] as! UILabel
            let barsContainer = row.subviews[1]
            
            // Позиционируем всю строку
            row.pin
                .top(CGFloat(index) * rowHeight)
                .horizontally(16) // Отступы слева и справа
                .height(rowHeight)
            
            // Лейбл возрастной группы (слева)
            groupLabel.pin
                .left()
                .width(groupLabelWidth)
                .vCenter()
                .height(16)
            
            // Контейнер с барами (справа от лейбла)
            barsContainer.pin
                .after(of: groupLabel)
                .marginLeft(8)
                .right()
                .height(rowHeight)
        }
    }
}
