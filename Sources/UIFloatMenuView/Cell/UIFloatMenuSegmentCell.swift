//
//  UIFloatMenuSegmentCell.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuSegmentCell: UITableViewCell {
    
    private var contentStackView: UIStackView = UIStackView()
    
    var items = [Any]()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIFloatMenuColors.revColor
        label.numberOfLines = 1
        label.isUserInteractionEnabled = false
        label.font = UIFloatMenuHelper.roundedFont(fontSize: 16, weight: .semibold)
        return label
    }()
    
    lazy var segmentView = UISegmentedControl(items: items)
    private var selectedIndex: Int!
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(contentStackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectedIndex = segmentView.selectedSegmentIndex
    }
    
    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        if selectedIndex != nil {
            segmentView.selectedSegmentIndex = selectedIndex
        }
        
        if titleLabel.text != "" {
            contentStackView.addArrangedSubview(titleLabel)
            contentStackView.spacing = 5
        } else {
            contentStackView.spacing = 0
        }
        contentStackView.addArrangedSubview(segmentView)
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fillProportionally

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
