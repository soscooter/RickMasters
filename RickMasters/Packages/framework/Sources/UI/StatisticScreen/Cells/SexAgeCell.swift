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
        let mockAgeDistribution = [10, 20, 5, 0, 5, 10, 0]
        configure(male: mockMale, female: mockFemale, ageDistribution: mockAgeDistribution)
        
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
    
    func configure(male: Int, female: Int, ageDistribution: [Int]) {
        pieChart.configure(male: CGFloat(Int(Double(male))), female: CGFloat(Int(Double(female))))
        maleLegend.text = "Мужчины \(male)%"
        femaleLegend.text = "Женщины \(female)%"
        ageChart.configure(with: ageDistribution)
    }
}

final class GenderPieChartView: UIView {
    
    private var femaleValue: CGFloat = 0
    private var maleValue: CGFloat = 0
    
    private let maleColor = UIColor(hex: "#FF2E00")
    private let femaleColor = UIColor(hex: "#FFAD8A")
    
    private let lineWidth: CGFloat = 6
    private let spacingAngle: CGFloat = .pi / 180 * 8  // 6 градусов (в обе стороны даст 12 между сегментами)
    
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
    private var bars: [UIProgressView] = []
    private var labels: [UILabel] = []
    private var percents: [UILabel] = []
    
    let ageGroups = ["18–21", "22–25", "26–30", "31–35", "36–40", "40–50", ">50"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        for _ in 0..<ageGroups.count {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 12)
            label.textColor = .black
            
            let bar = UIProgressView(progressViewStyle: .default)
            bar.trackTintColor = UIColor.clear
            bar.progressTintColor = UIColor(hex: "#FF2E00")
            
            let percent = UILabel()
            percent.font = UIFont.systemFont(ofSize: 12)
            percent.textColor = .black
            percent.textAlignment = .right
            
            addSubview(label)
            addSubview(bar)
            addSubview(percent)
            
            labels.append(label)
            bars.append(bar)
            percents.append(percent)
        }
    }
    
    func configure(with data: [Int]) {
        for (index, percent) in data.enumerated() {
            labels[index].text = ageGroups[index]
            bars[index].setProgress(Float(percent) / 100.0, animated: false)
            percents[index].text = "\(percent)%"
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for i in 0..<ageGroups.count {
            let top = CGFloat(i) * 32
            labels[i].pin.top(top).left(0).width(50).height(20)
            bars[i].pin.after(of: labels[i], aligned: .center).marginLeft(8).width(100).height(4)
            percents[i].pin.after(of: bars[i], aligned: .center).marginLeft(8).right(0).height(20)
        }
    }
}
