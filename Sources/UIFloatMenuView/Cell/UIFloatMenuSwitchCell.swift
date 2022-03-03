//
//  UIFloatMenuSwitchCell.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuSwitchCell: UITableViewCell {
    
    private var contentStackView: UIStackView = UIStackView()
    
    // MARK: Views
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIFloatMenuColors.revColor
        label.numberOfLines = 1
        label.isUserInteractionEnabled = false
        label.font = UIFloatMenuHelper.roundedFont(fontSize: 16, weight: .semibold)
        return label
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    lazy var switchView = UISwitch()
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(switchView)
        
        if iconImageView.image == nil {
            contentStackView.addArrangedSubview(titleLabel)
        } else {
            contentStackView.addArrangedSubview(iconImageView)
            contentStackView.addArrangedSubview(titleLabel)
        }
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.axis = .horizontal
        contentStackView.spacing = 9
        contentStackView.distribution = .fillProportionally
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalToConstant: 23),
            iconImageView.widthAnchor.constraint(equalToConstant: 23),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70)
        ])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        switchView.center.x = frame.width-38
        switchView.center.y = frame.height/2
        
        let templateImage = iconImageView.image?.withRenderingMode(.alwaysTemplate)
        iconImageView.image = templateImage
        iconImageView.tintColor = UIFloatMenuColors.revColor?.withAlphaComponent(0.65)
    }
}
