//
//  UIFloatMenuInfoCell.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuInfoCell: UITableViewCell {
    
    // MARK: Views
    private var contentStackView: UIStackView = UIStackView()
    
    var backView: UIView = {
        let uiview = UIView()
        uiview.layer.cornerRadius = 7
        uiview.isUserInteractionEnabled = false
        return uiview
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIFloatMenuColors.revColor?.withAlphaComponent(0.65)
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
        
        contentView.addSubview(backView)
        
        contentStackView.axis = .horizontal
        contentStackView.spacing = 9
        contentStackView.alignment = .center
        contentStackView.distribution = .fillProportionally
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        backView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 2),
            contentStackView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 14),
            contentStackView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -2),
            contentStackView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -14),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            titleLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setHighlighted
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            backView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.08)
        } else {
            backView.backgroundColor = .clear
        }
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
        
        backView.frame.size = CGSize(width: frame.width-20, height: frame.height-4)
        backView.center.x = frame.width/2
        backView.center.y = frame.height/2
    }
}
