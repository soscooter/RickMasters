//
//  SegmentControlCellCell.swift
//  framework
//
//  Created by Алексей Румынин on 29.05.25.
//

import UIKit

class SegmentControlCell: UICollectionViewCell {
    
    static let identifire: String = "SegmentControlCell"
    
    private let segmentControl: CustomSegmentedControl = {
        let segmentControl = CustomSegmentedControl()
        return segmentControl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(segmentControl)
        segmentControl.pin.all()

    }
    
    func configure(with segments: [String]){
            segmentControl.titles = segments
    }
    
}

class CustomSegmentedControl: UIStackView {

    private var buttons: [UIButton] = []
    private var selectedIndex: Int = 0

    var titles: [String] = [] {
        didSet {
            configureButtons()
        }
    }

    var onSegmentChanged: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStack()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStack()
    }

    private func setupStack() {
        axis = .horizontal
        distribution = .fillProportionally
        spacing = 8
        alignment = .fill
    }

    private func configureButtons() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.gilroyExtraBold(ofSize: 15)
            button.layer.cornerRadius = 16
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.backgroundColor = index == selectedIndex ? UIColor(hex: "#FF2E00") : .clear
            button.setTitleColor(index == selectedIndex ? UIColor(hex: "#FFFFFF") : UIColor(hex: "#000000"), for: .normal)

            button.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)

            buttons.append(button)
            addArrangedSubview(button)
        }
    }

    @objc private func segmentTapped(_ sender: UIButton) {
        guard let index = buttons.firstIndex(of: sender) else { return }

        selectedIndex = index
        updateButtonStates()
        onSegmentChanged?(index)
    }

    private func updateButtonStates() {
        for (index, button) in buttons.enumerated() {
            let isSelected = index == selectedIndex
            button.backgroundColor = isSelected ? .red : .white
            button.setTitleColor(isSelected ? .white : .black, for: .normal)
            button.layer.borderWidth = isSelected ? 0 : 1
        }
    }
}
