//
//  UIFloatMenuActionCell.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuActionCell: UITableViewCell {
    
    var itemColor: itemColor!
    var itemLayout: cellLayout!
    var itemHeight: heightStyle!
    
    var initBackColor: UIColor!
    
    // MARK: Views
    private var contentStackView: UIStackView = UIStackView()
    
    var backView: UIView = {
        let uiview = UIView()
        uiview.layer.cornerRadius = 8
        uiview.isUserInteractionEnabled = false
        return uiview
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIFloatMenuColors.revColor
        label.numberOfLines = 1
        label.isUserInteractionEnabled = false
        label.font = UIFloatMenuHelper.roundedFont(fontSize: 16, weight: .semibold)
        return label
    }()
    
    var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIFloatMenuColors.revColor
        label.numberOfLines = 1
        label.font = UIFloatMenuHelper.roundedFont(fontSize: 11, weight: .semibold)
        label.alpha = 0.8
        label.isUserInteractionEnabled = false
        return label
    }()
    
    var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
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
    
    // MARK: setHighlighted
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            switch itemColor {
            case .clear:
                let color = UIFloatMenuHelper.detectTheme(dark: UIColor.lightGray.withAlphaComponent(0.08),
                                                     light: UIColor.lightGray.withAlphaComponent(0.12),
                                                     any: UIColor.lightGray.withAlphaComponent(0.08))
                backView.backgroundColor = color
                break
            case .tinted(_):
                break
            case .filled(_):
                backView.alpha = 0.9
                break
            case .standard:
                backView.alpha = 0.9
                break
            case .custom(_, let tintColor, let backColor):
                if backColor == .clear {
                    backView.backgroundColor = tintColor.withAlphaComponent(0.1)
                }
                break
            case .none:
                break
            }
        } else {
            backView.backgroundColor = initBackColor
            backView.alpha = 1
        }
    }
    
    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(backView)
        
        if iconImageView.image != nil {
            backView.addSubview(iconImageView)
        }
        
        backView.frame.size = CGSize(width: frame.width-20, height: frame.height-5)
        backView.center.x = frame.width/2
        backView.center.y = frame.height/2
        
        contentStackView.axis = .vertical
        contentStackView.distribution = .fillProportionally
        
        if subtitleLabel.text != "" {
            contentStackView.addArrangedSubview(titleLabel)
            contentStackView.addArrangedSubview(subtitleLabel)
        } else {
            contentStackView.addArrangedSubview(titleLabel)
        }
        
        addSubview(contentStackView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let top_bottom: CGFloat = (itemHeight == .standard ? 10 : 7)
        
        switch itemLayout {
        case .Icon_Title:
            if iconImageView.image != nil {
                iconImageView.frame.origin.x = 10
            }
            
            NSLayoutConstraint.activate([
                contentStackView.topAnchor.constraint(equalTo: backView.topAnchor, constant: top_bottom),
                contentStackView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: iconImageView.image != nil ? 40 : 10),
                contentStackView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -top_bottom),
                contentStackView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -10)
            ])
            break
        case .Title_Icon:
            if iconImageView.image != nil {
                iconImageView.frame.origin.x = backView.frame.width-35
            }
            
            NSLayoutConstraint.activate([
                contentStackView.topAnchor.constraint(equalTo: backView.topAnchor, constant: top_bottom),
                contentStackView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 10),
                contentStackView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -top_bottom),
                contentStackView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: iconImageView.image != nil ? -40 : -10)
            ])
            break
        case .none:
            break
        }
        
        contentStackView.isUserInteractionEnabled = false
        
        iconImageView.frame.size = CGSize(width: 23, height: 23)
        iconImageView.center.y = backView.frame.height/2
        
        switch itemColor {
        case .clear:
            if iconImageView.image != nil {
                let templateImage = iconImageView.image?.withRenderingMode(.alwaysTemplate)
                iconImageView.image = templateImage
                iconImageView.tintColor = UIFloatMenuColors.revColor
            }
            break
        case .tinted(let color):
            if iconImageView.image != nil {
                let templateImage = iconImageView.image?.withRenderingMode(.alwaysTemplate)
                iconImageView.image = templateImage
                iconImageView.tintColor = color
            }
            
            titleLabel.textColor = color
            subtitleLabel.textColor = color.withAlphaComponent(0.9)
            
            backView.backgroundColor = color.withAlphaComponent(0.1)
            break
        case .filled(let color):
            if iconImageView.image != nil {
                let templateImage = iconImageView.image?.withRenderingMode(.alwaysTemplate)
                iconImageView.image = templateImage
                iconImageView.tintColor = .white
            }
            
            titleLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
            
            backView.backgroundColor = color
            break
        case .standard:
            if iconImageView.image != nil {
                let templateImage = iconImageView.image?.withRenderingMode(.alwaysTemplate)
                iconImageView.image = templateImage
                iconImageView.tintColor = UIFloatMenuColors.revColor
            }
            
            titleLabel.textColor = UIFloatMenuColors.revColor
            subtitleLabel.textColor = UIFloatMenuColors.revColor
            
            backView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.08)
            break
        case .custom(let iconColor, let textColor, let backColor):
            let image = iconColor != .clear ? iconImageView.image?.withRenderingMode(.alwaysTemplate) : iconImageView.image
            iconImageView.image = image
            iconImageView.tintColor = iconColor
            
            titleLabel.textColor = textColor
            subtitleLabel.textColor = textColor.withAlphaComponent(0.9)
            
            if backColor != .clear {
                backView.backgroundColor = backColor
            }
            break
        case .none:
            break
        }
    }
}
