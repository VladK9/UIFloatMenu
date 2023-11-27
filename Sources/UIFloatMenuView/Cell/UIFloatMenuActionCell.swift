//
//  UIFloatMenuActionCell.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuActionCell: UITableViewCell {
    
    var itemColor: itemSetup.itemColor!
    var itemLayout: itemSetup.cellLayout!
    var itemHeight: itemSetup.heightStyle!
    
    var selection: itemSetup.selectionConfig!
    
    var initBackColor: UIColor!
    
    // MARK: Views
    private var labelsStackView: UIStackView = UIStackView()
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
        
        contentView.addSubview(backView)
        
        labelsStackView.axis = .vertical
        labelsStackView.distribution = .fillProportionally
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        if subtitleLabel.text != "" {
            labelsStackView.addArrangedSubview(titleLabel)
            labelsStackView.addArrangedSubview(subtitleLabel)
        } else {
            labelsStackView.addArrangedSubview(titleLabel)
        }
        
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.alignment = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentStackView)
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
                backView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.08)
                break
            case .tinted(_):
                backView.alpha = UIFloatMenuHelper.theme() == .dark ? 0.8 : 0.7
                break
            case .filled(_):
                backView.alpha = 0.9
                break
            case .default:
                backView.alpha = UIFloatMenuHelper.theme() == .dark ? 0.7 : 0.6
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
        backView.frame.size = CGSize(width: frame.width-20, height: frame.height-5)
        backView.center.x = frame.width/2
        backView.center.y = frame.height/2
        
        if iconImageView.image != nil {
            if case .Icon_Title = itemLayout {
                contentStackView.addArrangedSubview(iconImageView)
                contentStackView.addArrangedSubview(labelsStackView)
            } else {
                contentStackView.addArrangedSubview(labelsStackView)
                contentStackView.addArrangedSubview(iconImageView)
            }
            contentStackView.spacing = 12
        } else {
            contentStackView.addArrangedSubview(labelsStackView)
        }
        
        var top_bottom: CGFloat {
            switch itemHeight {
            case .default:
                return 10
            case .compact:
                return 7
            case .big:
                return 16
            case .none:
                break
            }
            return 0
        }
        
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalToConstant: 23),
            iconImageView.widthAnchor.constraint(equalToConstant: 23),
            contentStackView.topAnchor.constraint(equalTo: backView.topAnchor, constant: top_bottom),
            contentStackView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 14),
            contentStackView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -top_bottom),
            contentStackView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -14)
        ])
        
        backView.layer.borderWidth = 0.6
        
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
            backView.layer.borderColor = color.withAlphaComponent(0.05).cgColor
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
            backView.layer.borderColor = color.withAlphaComponent(0.05).cgColor
            break
        case .default:
            if iconImageView.image != nil {
                let templateImage = iconImageView.image?.withRenderingMode(.alwaysTemplate)
                iconImageView.image = templateImage
                iconImageView.tintColor = UIFloatMenuColors.revColor
            }
            
            titleLabel.textColor = UIFloatMenuColors.revColor
            subtitleLabel.textColor = UIFloatMenuColors.revColor
            
            backView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.08)
            backView.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.05).cgColor
            break
        case .custom(let iconColor, let textColor, let backColor):
            let image = iconColor != .clear ? iconImageView.image?.withRenderingMode(.alwaysTemplate) : iconImageView.image
            iconImageView.image = image
            iconImageView.tintColor = iconColor
            
            titleLabel.textColor = textColor
            subtitleLabel.textColor = textColor.withAlphaComponent(0.9)
            
            if backColor != .clear {
                backView.backgroundColor = backColor
                backView.layer.borderColor = backColor.withAlphaComponent(0.05).cgColor
            }
            break
        case .none:
            break
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if case .multi(_, let selectedIcon, let selectedTitle, let defaultIcon, let defaultTitle) = selection {
            if selected {
                titleLabel.text = selectedTitle
                if selectedIcon != nil {
                    iconImageView.image = selectedIcon
                }
            } else {
                titleLabel.text = defaultTitle
                if defaultIcon != nil {
                    iconImageView.image = defaultIcon
                }
            }
        }
    }
    
}
