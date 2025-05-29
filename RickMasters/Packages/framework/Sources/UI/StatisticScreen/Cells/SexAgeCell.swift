//
//  SexAgeCell.swift
//  framework
//
//  Created by Алексей Румынин on 27.05.25.
//

import UIKit
import Charts
import PinLayout
import DGCharts

class SexAgeCell: UICollectionViewCell {
    
    private let chartsView: GraphView = GraphView()
    
    static let identifire: String = "SexAgeCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
        contentView.addSubview(chartsView)
        chartsView.pin.all()
    }
    
}

final class GraphView: UIView {
    private let chartView: LineChartView = {
        let chart = LineChartView()
        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = .bottom
        chart.legend.enabled = false
        chart.animate(xAxisDuration: 0.3)
        chart.setScaleEnabled(false) // Отключаем зумирование
        chart.pinchZoomEnabled = false // Отключаем pinch-зум
        chart.doubleTapToZoomEnabled = false // Отключаем двойной тап для зума
        chart.highlightPerDragEnabled = false // Отключаем подсветку при драге
        
        chart.highlightPerTapEnabled = true // Разрешаем подсветку по тапу
            chart.drawMarkers = true // Включаем маркеры
//            let highlight = Highlight()
////            highlight.drawEnabled = true
//            highlight.highlightColor = .clear // Прозрачный цвет креста
//            chart.highlightValues([highlight])
        return chart
    }()
    
    // Массив дат для оси X
    private let dates = ["05.03", "06.03", "07.03", "08.03", "09.03", "10.03", "11.03"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(chartView)
        setupChartData()
        configureMarker()
        configureXAxis()
        configureYAxis() // Добавляем настройку оси Y
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.pin.all()
    }
    
    private func configureXAxis() {
        let xAxis = chartView.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
        xAxis.granularity = 1
        xAxis.labelCount = dates.count
        xAxis.avoidFirstLastClippingEnabled = true
        xAxis.drawGridLinesEnabled = false // Убираем сетку по оси X
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.1)
    }
    
    private func configureYAxis() {
        let leftAxis = chartView.leftAxis
        leftAxis.drawLabelsEnabled = false // Убираем значения по оси Y
        leftAxis.axisMinimum = 0 // Минимальное значение
        leftAxis.axisMaximum = 40 // Максимальное значение
        leftAxis.drawGridLinesEnabled = true // Оставляем сетку
        leftAxis.setLabelCount(3, force: true) // Принудительно устанавливаем 3 метки
        leftAxis.granularity = 20 // Шаг между линиями
        leftAxis.gridLineDashLengths = [10, 3] // Длина штриха и пробела
            leftAxis.gridLineDashPhase = 0
        leftAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.3) // Цвет сетки
        leftAxis.gridLineWidth = 1 // Толщина линий сетки
    }
    
    private func setupChartData() {
        let values: [ChartDataEntry] = [
            ChartDataEntry(x: 0, y: 15), // 05.03
            ChartDataEntry(x: 1, y: 21), // 06.03
            ChartDataEntry(x: 2, y: 18), // 07.03
            ChartDataEntry(x: 3, y: 22), // 08.03
            ChartDataEntry(x: 4, y: 14), // 09.03
            ChartDataEntry(x: 5, y: 14), // 10.03
            ChartDataEntry(x: 6, y: 22)  // 11.03
        ]

        let dataSet = LineChartDataSet(entries: values, label: "")
        
        // Основные настройки линии
        dataSet.mode = .linear
        dataSet.lineWidth = 4
        dataSet.setColor(UIColor(hex: "#FF2E00") ?? .red)
        
        // Настройка точек
        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 8
        dataSet.setCircleColor(UIColor(hex: "#FF2E00") ?? .red)
        dataSet.circleHoleColor = .white
        dataSet.circleHoleRadius = 4
        
        // Настройка подсветки при нажатии
        dataSet.highlightColor = UIColor(hex: "#FF2E00") ?? .red
        dataSet.highlightLineWidth = 2
        dataSet.highlightLineDashLengths = [10, 3] // Пунктирная линия
        dataSet.drawHorizontalHighlightIndicatorEnabled = false // Горизонтальная линия
        dataSet.drawVerticalHighlightIndicatorEnabled = true // Отключаем вертикальную
        
        // Отключение значений над точками
        dataSet.drawValuesEnabled = false
        dataSet.valueTextColor = .clear
        dataSet.valueFont = .systemFont(ofSize: 0)
        
        // Настройка заполнения под линией (если нужно)
        dataSet.drawFilledEnabled = false
        
        // Создаем объект данных графика
        let data = LineChartData(dataSet: dataSet)
        data.setDrawValues(false)
        
        // Применяем данные к графику
        chartView.data = data
        
        // Дополнительные настройки для плавности
        chartView.animate(xAxisDuration: 0.8, yAxisDuration: 0.8)
    }
    
    private func configureMarker() {
        let marker = VisitorMarkerView(color: UIColor(hex: "#E4E4E9")!, font: UIFont.gilroyExtraBold(ofSize: 15), textColor: UIColor(hex: "#FF2E00")!)
        marker.chartView = chartView
        marker.dates = dates
        chartView.marker = marker
    }
}

final class VisitorMarkerView: MarkerView {
    private let label = UILabel()
    var dates: [String] = [] // Массив дат для отображения в маркере
    
    init(color: UIColor, font: UIFont, textColor: UIColor) {
        super.init(frame: .zero)
        backgroundColor = color
        layer.cornerRadius = 8
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        
        label.font = font
        label.textColor = textColor
        label.textAlignment = .center
        label.numberOfLines = 2
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let dateIndex = Int(entry.x)
        guard dateIndex >= 0 && dateIndex < dates.count else {
            label.text = "\(Int(entry.y)) посетитель"
            return
        }
        
        label.text = "\(Int(entry.y)) посетителей\n\(dates[dateIndex])"
        label.sizeToFit()
        label.pin
            .width(128)
            .height(72)
        frame.size = CGSize(width: label.frame.width , height: label.frame.height )
    }
    
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        CGPoint(x: -frame.width / 2, y: -frame.height - 10)
    }
    
    override func draw(context: CGContext, point: CGPoint) {
        super.draw(context: context, point: point)
        // Отрисовываем сам маркер
        self.center = CGPoint(x: point.x, y: point.y + offsetForDrawing(atPoint: point).y)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.pin.all(8)
    }
}

