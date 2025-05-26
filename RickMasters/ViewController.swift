//
//  ViewController.swift
//  RickMasters
//
//  Created by Алексей Румынин on 25.05.25.
//

import UIKit
import PinLayout

class ViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont(name: "Gilroy-ExtraBold", size: 32)
        //        label.textColor = UIColor(hex: "#2D2D2DFF")
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F6F6F6FF")
//        setupView()
    }
    
    private func setupView(){
        
        view.addSubview(titleLabel)
        titleLabel.pin
//            .top(to: .safeArea).marginTop(48)
            .horizontally(16)
            .sizeToFit()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeTop = view.safeAreaInsets.top

        view.addSubview(titleLabel)
        titleLabel.pin
            .top(safeTop + 48)
            .horizontally(16)
            .sizeToFit()
    }
    
}
