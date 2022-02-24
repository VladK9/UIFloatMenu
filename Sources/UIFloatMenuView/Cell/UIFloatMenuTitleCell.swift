//
//  UIFloatMenuTitleCell.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuTitleCell: UITableViewCell {
    
    // MARK: Views
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIFloatMenuColors.revColor
        label.numberOfLines = 1
        label.isUserInteractionEnabled = false
        label.font = UIFloatMenuHelper.roundedFont(fontSize: 16, weight: .semibold)
        return label
    }()
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(titleLabel)
        
        titleLabel.frame.size = CGSize(width: frame.width-50, height: 20)
        titleLabel.center.y = frame.height/2
        titleLabel.frame.origin.x = 10
    }
}
