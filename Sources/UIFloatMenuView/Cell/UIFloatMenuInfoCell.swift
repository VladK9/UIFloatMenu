//
//  UIFloatMenuInfoCell.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuInfoCell: UITableViewCell {
    
    // MARK: Views
    private var contentStackView: UIStackView = UIStackView()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIFloatMenuColors.revColor
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        return label
    }()
    
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
        if iconImageView.image == nil {
            contentStackView.addArrangedSubview(titleLabel)
        } else {
            contentStackView.addArrangedSubview(iconImageView)
            contentStackView.addArrangedSubview(titleLabel)
        }
        
        contentStackView.axis = .horizontal
        contentStackView.spacing = 9
        contentStackView.distribution = .fillProportionally
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalToConstant: 23),
            iconImageView.widthAnchor.constraint(equalToConstant: 23),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -13)
        ])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let templateImage = iconImageView.image?.withRenderingMode(.alwaysTemplate)
        iconImageView.image = templateImage
        iconImageView.tintColor = UIFloatMenuColors.revColor?.withAlphaComponent(0.65)
    }
}
