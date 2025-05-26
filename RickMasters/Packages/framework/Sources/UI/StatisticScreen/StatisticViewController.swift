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
    
    private let statisticService = StatisticService()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F6F6F6FF")
        statisticService.fetchUsers()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupView()
    }
    
    private func setupView(){
        
        view.addSubview(titleLabel)
        
        let safeTop = view.safeAreaInsets.top
        
        view.addSubview(titleLabel)
        titleLabel.pin
            .top(safeTop + 48)
            .horizontally(16)
            .sizeToFit()
        
    }
    
}
