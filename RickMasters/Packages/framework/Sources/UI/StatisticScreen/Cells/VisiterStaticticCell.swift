//
//  VisiterStaticticCell.swift
//  framework
//
//  Created by Алексей Румынин on 27.05.25.
//

import UIKit
import Charts
import PinLayout
import DGCharts

class VisiterStaticticCell: UICollectionViewCell {
    
    private let chartsView: GraphView = GraphView()
    static let identifire: String = "VisiterStaticticCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(chartsView)
        chartsView.pin.all()
    }
    
    func configure(with statistics: [Statistic]) {
        
        let dateCounts = processDates(statistics: statistics)
        let sortedDates = dateCounts.sorted { $0.key < $1.key }
        let (chartData, formattedDates) = convertToChartData(dateCounts: sortedDates)
        chartsView.updateChart(with: chartData, dates: formattedDates)
    }
    
    private func processDates(statistics: [Statistic]) -> [Int: Int] {
        var dateCounts = [Int: Int]()
        
        for stat in statistics {
            for date in stat.dates {
                dateCounts[date] = (dateCounts[date] ?? 0) + 1
            }
        }
        return dateCounts
    }
    
    private func convertToChartData(dateCounts: [(key: Int, value: Int)]) -> (entries: [ChartDataEntry], dates: [String]) {
        var formattedDates = [String]()
        var entries = [ChartDataEntry]()
        
        // Сортируем даты
        let sortedDates = dateCounts.sorted { $0.key < $1.key }
        
        // Обрабатываем каждую дату
        for (index, item) in sortedDates.enumerated() {
            let dateString = String(item.key)
            let formattedDate: String
            
            // Обрабатываем 7-значные даты (dMMyyyy)
            if dateString.count == 7 {
                let day = String(dateString.prefix(1))
                let month = String(dateString.dropFirst(1).prefix(2))
                let year = String(dateString.dropFirst(3))
                formattedDate = "\(day).\(month)"
            }
            // Обрабатываем 8-значные даты (ddMMyyyy)
            else if dateString.count == 8 {
                let day = String(dateString.prefix(2))
                let month = String(dateString.dropFirst(2).prefix(2))
                formattedDate = "\(day).\(month)"
            } else {
                formattedDate = "N/A"
            }
            
            formattedDates.append(formattedDate)
            entries.append(ChartDataEntry(x: Double(index), y: Double(item.value)))
        }
        
        return (entries, formattedDates)
    }
}

final class GraphView: UIView {
    private let chartView: LineChartView = {
        let chart = LineChartView()
        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = .bottom
        chart.legend.enabled = false
        chart.animate(xAxisDuration: 0.3)
        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.highlightPerDragEnabled = false
        chart.highlightPerTapEnabled = true
        chart.drawMarkers = true
        return chart
    }()
    
    private var dates: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(chartView)
        configureAxes()
        configureMarker()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.pin.all()
    }
    
    func updateChart(with entries: [ChartDataEntry], dates: [String]) {
        let dataSet = LineChartDataSet(entries: entries, label: "Посетители")
        configureDataSet(dataSet: dataSet)
        
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
        
        // Обновляем даты на оси X
        let xAxis = chartView.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
        self.dates = dates
        xAxis.labelCount = dates.count
        xAxis.labelFont = UIFont.gilroyLight(ofSize: 11)
        xAxis.labelTextColor = UIColor(hex: "#A7A7B1")!
        
        let yAxis = chartView.leftAxis
        yAxis.setLabelCount(3, force: true)
        yAxis.axisMaximum = dataSet.yMax + dataSet.yMin
        yAxis.granularity = dataSet.yMax / 2
        
        configureMarker()
        
        chartView.animate(yAxisDuration: 0.8)
    }
    
    private func configureDataSet(dataSet: LineChartDataSet) {
        dataSet.mode = .linear
        dataSet.lineWidth = 4
        dataSet.setColor(UIColor(hex: "#FF2E00") ?? .red)
        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 8
        dataSet.setCircleColor(UIColor(hex: "#FF2E00") ?? .red)
        dataSet.circleHoleColor = .white
        dataSet.circleHoleRadius = 4
        dataSet.highlightColor = UIColor(hex: "#FF2E00") ?? .red
        dataSet.highlightLineWidth = 2
        dataSet.highlightLineDashLengths = [10, 3]
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.drawVerticalHighlightIndicatorEnabled = true
        dataSet.drawValuesEnabled = false
    }
    
    private func configureAxes() {
        let xAxis = chartView.xAxis
        xAxis.granularity = 1
        xAxis.avoidFirstLastClippingEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = UIColor.lightGray.withAlphaComponent(0)
        xAxis.drawAxisLineEnabled = false
        
        let leftAxis = chartView.leftAxis
        leftAxis.drawLabelsEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 40
        leftAxis.drawGridLinesEnabled = true
        leftAxis.setLabelCount(3, force: true)
        leftAxis.granularity = 20
        leftAxis.gridLineDashLengths = [10, 3]
        leftAxis.gridLineDashPhase = 0
        leftAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.3)
        leftAxis.gridLineWidth = 1
        leftAxis.drawAxisLineEnabled = false
    }
    
    private func configureMarker() {
        let marker = VisitorMarkerView(
            color: UIColor(hex: "#E4E4E9")!,
            font: UIFont.gilroyExtraBold(ofSize: 14),
            textColor: UIColor(hex: "#FF2E00")!,
            dates: self.dates
        )
        marker.chartView = chartView
        chartView.marker = marker
    }
}

final class VisitorMarkerView: MarkerView {
    private let countLabel = UILabel()
    private let dateLabel = UILabel()
    
    var dates: [String]
    
    init(color: UIColor, font: UIFont, textColor: UIColor,dates: [String]) {
        self.dates = dates
        super.init(frame: .zero)
        backgroundColor = UIColor(hex: "#FFFFFF")
        layer.cornerRadius = 12
        layer.borderColor = UIColor(hex: "#E4E4E9")?.cgColor
        layer.borderWidth = 1
        
        countLabel.font = font
        countLabel.textColor = textColor
        countLabel.numberOfLines = 1
        countLabel.textAlignment = .left
        
        // Настройка label для даты
        dateLabel.font = UIFont.gilroyLight(ofSize: 13)
        dateLabel.textColor = UIColor(hex: "#000000")
        dateLabel.numberOfLines = 1
        dateLabel.textAlignment = .left
        
        addSubview(countLabel)

        addSubview(dateLabel)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        countLabel.pin
            .top(16)
            .horizontally(16)
            .sizeToFit(.width)

        dateLabel.pin
            .below(of: countLabel)
            .marginTop(8)
            .horizontally(16)
            .bottom(16)
            .sizeToFit(.width)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func pluralForm(for count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100

        if remainder10 == 1 && remainder100 != 11 {
            return "посетитель"
        } else if (2...4).contains(remainder10) && !(12...14).contains(remainder100) {
            return "посетителя"
        } else {
            return "посетителей"
        }
    }
    
    private func formatDate(from input: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "d.MM"
        inputFormatter.locale = Locale(identifier: "ru_RU")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM"
        outputFormatter.locale = Locale(identifier: "ru_RU")

        if let date = inputFormatter.date(from: input) {
            return outputFormatter.string(from: date)
        } else {
            return input
        }
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let dateIndex = Int(entry.x)
            guard dateIndex >= 0 && dateIndex < dates.count else { return }

            let count = Int(entry.y)
            let dateString = dates[dateIndex]

            countLabel.text = "\(count) \(pluralForm(for: count))"
            dateLabel.text = formatDate(from: dateString)

            setNeedsLayout()
            layoutIfNeeded()
        frame.size = CGSize(
            width: 135,
            height: 72
        )
        
    }
    
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        CGPoint(x: -frame.width / 2, y: -frame.height - 10)
    }
    
    override func draw(context: CGContext, point: CGPoint) {
        super.draw(context: context, point: point)
        self.center = CGPoint(x: point.x, y: point.y + offsetForDrawing(atPoint: point).y)
    }
}

