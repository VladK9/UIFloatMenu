//
//  CustomCell.swift
//  UIFloatMenuExample
//
//  Created by Владислав on 04.06.2022.
//

import UIKit
import Foundation

class UIFloatMenuCustomCell: UITableViewCell {
    
    var customView = UIView()
    
    private var isReused: Bool = false
    private var isLoaded: Bool = false
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isReused = true
        isLoaded = true
    }
    
    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isReused && isLoaded == false {
            contentView.addSubview(customView)
            customView.frame.size.width = frame.width-20
            customView.center.x = frame.width/2
            customView.center.y = frame.height/2
        }
        isLoaded = true
    }
    
    // MARK: setHighlighted
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            customView.alpha = UIFloatMenuHelper.theme() == .dark ? 0.7 : 0.6
        } else {
            customView.alpha = 1
        }
    }
    
}
